//
//  Scoreboard.swift
//  Statter
//
//  Created by gandreas on 7/19/23.
//

import Foundation
import SwiftUI

//@dynamicMemberLookup
class Connection : ObservableObject, Equatable {
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.webSocket == rhs.webSocket && lhs.webSocketURL == rhs.webSocketURL
    }
    
    enum Errors : Error {
        case noConnection
    }
    var host: String? = "10.0.0.10"
    var port: Int = 8000
    
    #if os(watchOS)
    var operatorName: String = "statterWatch"
    #else
    var operatorName: String = "statter"
    #endif
    enum Source : String {
        case root
        case sbo = "/nso/sbo"
        case sb = "/views/standard"
    }
    @Published var source: Source = .root {
        didSet {
            webSocket?.cancel(with: .normalClosure, reason: nil)
            webSocket = nil
            state = [:]
            connect()
        }
    }
    var baseURL: URL? {
        guard let host else {
            return nil
        }
        return URL(string: "ws://\(host):\(port)/WS")
    }
    /// The URL for the web socket API
    var webSocketURL: URL? {
        let source: String
        if let gameID = game?.id {
            source = self.source.rawValue + "?game=\(gameID)&operator=\(operatorName)"
        } else {
            source = self.source.rawValue + "?operator=\(operatorName)"
        }
//        #if os(watchOS)
//        let platform = "appleWatch; ARM64 Mac OS X 10_15_7"
//        #else
        let platform = "Macintosh; Intel Mac OS X 10_15_7"
//        #endif
        return baseURL?.appending(queryItems: [
//            .init(name:"source", value: "/nso/sbo/?game=b6003f5f-f4a4-477c-8856-ccdf363fa4ff"),
            // This is not required, but helps figure out which device is which.
//            .init(name:"source", value: "/nso/plt/?zoomable=0&team=1&game=b6003f5f-f4a4-477c-8856-ccdf363fa4ff"),
            .init(name:"source", value:source),
            .init(name:"platform", value: platform)
        ])
    }


    var urlSession : URLSession = .shared

    /// The current web socket task - use a single web socket if possible
    @Published var webSocket : URLSessionWebSocketTask?

    func createWebSocket() -> URLSessionWebSocketTask? {
        guard let webSocketURL else {
            return nil
        }
        var urlRequest = URLRequest(url: webSocketURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)

        // add the protocol we support
//        urlRequest.addValue("graphql-transport-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol") // newer server
        urlRequest.addValue("websocket", forHTTPHeaderField: "Upgrade")
        urlRequest.addValue("Upgrade", forHTTPHeaderField: "Connection")

        let retval = urlSession.webSocketTask(with: urlRequest)
//            retval.delegate = delegate
        return retval
    }
    
    func checkWSCloseError() {
        guard let closeReason = webSocket?.closeReason,
              let closeReasonString = String(data: closeReason, encoding: .utf8) else {
            return
        }
        print("WS:Close Error [\(webSocket?.taskIdentifier ?? -1)]\(webSocket!.closeCode.rawValue) '\(closeReasonString)'")
    }

    
    /// The first step on openning a web socket, which opens the we socket, authorizes it,
    /// and then finally calls the closure
    /// - Parameter then: The closure to call after openning and authenticating the web socket
    func openWebSocket(then: @escaping (Result<URLSessionWebSocketTask, Error>)->Void) {
        if let webSocket = webSocket {
            then(.success(webSocket))
        } else {
            guard let socket = createWebSocket() else {
                then(.failure(Errors.noConnection))
                return
            }
            webSocket = socket
            socket.resume()
            print("WS:Starting ping [\(socket.taskIdentifier)]")
            sendDelayedPing(socket)
            then(.success(socket))
        }
    }

    /// A count of the number of pings that have failed in the websocket task
    /// Note this needs to be per socket (since reconnecting after suspension will
    /// cause multiple task - both one that works and another that fails, with the
    /// working one reseting "failed" to zero and the failing one never going away)
    var failedPings : [Int: Int] = [:]
    /// A ping that we send (every 10 seconds) to make sure the websocket stays alive
    /// - Parameter socket: The socket task to ping.
    func sendDelayedPing(_ socket: URLSessionWebSocketTask, delay: TimeInterval = 30.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("WS: Websocket ping")
            socket.sendPing { [self] error in
                let nextDelay: TimeInterval
                if let error = error {
                    print("WS: ping error [\(socket.taskIdentifier)] \(error)")
                    nextDelay = 3 // every 3 seconds if we fail
                    self.failedPings[socket.taskIdentifier] = self.failedPings[socket.taskIdentifier, default: 0] + 1
//                    failedPings += 1
                    if self.failedPings[socket.taskIdentifier, default: 0] >= 3 {
                        // well now we've got problems
                        self.failedPings[socket.taskIdentifier] = nil
                        if self.webSocket == socket {
                            DispatchQueue.main.async {
                                self.webSocket = nil // try opening a new connection (but only if it is this socket)
                                // indicate that things bailed after we nilled out websocket
                                // so we don't open one just before closing it.  Don't complain
                                // if our socket isn't the "current" socket
                                self.webSocketFailedHandler?()
                            }
                        }
                        return // and don't keep pinging
                    }
                } else {
                    self.failedPings[socket.taskIdentifier] = nil
                    nextDelay = 20 // only every 20 seconds if we work
//                    failedPings = 0
//                    gLog.status("Websocket pong")
                }
                self.sendDelayedPing(socket, delay: nextDelay)
            }
        }
    }

    /// The handler to call on web socket failure
    public var webSocketFailedHandler: (()->Void)?

    @Published var error: Error?
    func connect() {
        openWebSocket { [self] result in
            switch result {
            case .failure(let error):
                self.error = error
            case .success(_):
                self.error = nil
                _ = ws.device.name // this will register it
                _ = scoreBoard.currentGame.game
                _ = ws.device.id
                _ = ws.client.remoteAddress
//                _ = scoreBoard.version(.release)
                _ = scoreBoard.version[.release]
                _ = scoreBoard.clients.device().comment
                self.getPacket()
            }
        }
    }
    
    var ws: WS { .init(connection: self) }
    var scoreBoard: ScoreBoard { .init(connection: self) }
    
    var toRegister: [PathSpecified] = []
    func register(path: PathSpecified) {
//        print("=== Register \(path.statePath.description)")
        if toRegister.contains(where: { $0.statePath.description == path.statePath.description }) {
            return
        }
        toRegister.append(path)
        DispatchQueue.main.async {
            guard self.toRegister.isEmpty == false else {
                return
            }
            self.register()
        }
    }
    /// Register paths with the scoreboard
    /// - Parameter paths: Paths to explicitly register
    ///
    /// Note that any access to a ``Leaf`` value will implicitly register
    /// that with the scoreboard, but those registrations won't happen
    /// until this routine is called (which will happen automatically ever time
    /// we process a message from the server)
    func register(_ paths: PathSpecified...) {
        guard let webSocket else {
//            print("Defer Registering for \(paths.map{$0.statePath.description}.joined(separator: ", "))")
            toRegister.append(contentsOf: paths)
            return
        }
        struct RegisterCommand: Codable {
            var action: String = "Register"
            var paths: [StatePath]
        }
        let command = RegisterCommand(paths: toRegister.map{$0.statePath} + paths.map{$0.statePath})
        toRegister = []
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        if let data = try? encoder.encode(command), let src = String(data: data, encoding: .utf8) {
//            print(">>> Sent \(src)")
            webSocket.send(.string(src)) { error in
                // we use the callback version since this is self contained anyway
                DispatchQueue.main.async {
                    if error == nil {
//                        print("Registered for \((command.paths.map{$0.description}).joined(separator: ", "))")
                    } else {
                        print(error!)
                        self.error = error
                    }
                }
            }
        }
    }
    @Published var deviceName: String?
        
    @Published var game: Game?
    
    func getPacket() {
        if toRegister.isEmpty == false {
            // we had stuff to register initially but couldn't
            register()
        }
        webSocket?.receive { result in
//            print("<<< \(result)")
            DispatchQueue.main.async { [self] in
                switch result {
                case .failure(let error):
                    self.error = error
                case .success(let message):
                    let data: Data?
                    switch message {
                    case .data(let d): data = d
                    case .string(let s): data = s.data(using: .utf8)
                    @unknown default:
                        fatalError()
                    }
                    struct StateMessage: Decodable {
                        var state: [String : JSONValue]
                    }
                    if let data, let newState = try? JSONDecoder().decode(StateMessage.self, from: data) {
                        self.objectWillChange.send()
                        for newStatePair in newState.state {
                            // should check the key for special handling
                            let key = StatePath(from: newStatePair.key)
                            switch key.description {
                            case "WS.Device.Name":
                                deviceName = newStatePair.value.stringValue
                            case "ScoreBoard.CurrentGame.Game":
//                                print("Current game = \(newStatePair.value)")
                                guard let id = newStatePair.value.stringValue.flatMap({UUID(uuidString: $0)}) else {
                                    break
                                }
                                self.game = ScoreBoard(connection: self).game(id)
                            default:
                                break
                            }
                            state[key] = newStatePair.value
                        }
                    } else {
                        if let data {
//                            print("Unable to decode data")
                            if let string = String(data: data, encoding: .utf8) {
                                print(string)
                            }
                        }
                    }
                    error = nil
                    getPacket()
                }
            }
        }
    }
    
    var state: [StatePath: JSONValue] = [:]
    
    subscript(path: PathSpecified) -> JSONValue? {
        state[path.statePath]
    }
}