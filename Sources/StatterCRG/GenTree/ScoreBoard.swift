// ScoreBoard.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct ScoreBoard : PathSpecified {
    public var connection: Connection
    public var statePath: StatePath { .init(components: [.plain("ScoreBoard")])}

    //    node CurrentGame

    //        var Game UUID

    //        var InJam Bool

    //        var OfficialReview Bool

    //    end

    public var currentGame: Game { Game(parent: self, statePath: self.adding("CurrentGame"))}

    public struct Clients : PathNode {
        public var parent: ScoreBoard
        public let statePath: StatePath
        public struct Device : PathNodeId, Identifiable {
            public var parent: Clients
            public var id: UUID? { UUID.from(component: statePath.last)?.1 }
            public let statePath: StatePath
            @Leaf public var comment: String?

            public init(parent: Clients, id: UUID? = nil) {
                self.parent = parent
                if let id {
                    statePath = parent.adding(.id("Device", id: id))
                } else {
                    statePath =  parent.adding(.wild("Device"))
                }
        
                _comment = parent.leaf("Comment")
                _comment.parentPath = statePath
            }
            public init(parent: Clients, statePath: StatePath) {
                self.parent = parent
                self.statePath = statePath
                _comment = parent.leaf("Comment")
                _comment.parentPath = statePath
            }
        }
        public func device(_ id: UUID? = nil) -> Device { .init(parent: self, id: id) }
        public init(parent: ScoreBoard) {
            self.parent = parent
            statePath = parent.adding("Clients")
    
        }
        public init(parent: ScoreBoard, statePath: StatePath) {
            self.parent = parent
            self.statePath = statePath
        }
    }
    public var clients: Clients { .init(parent: self) }
    

    public enum Version: String, EnumStringAsID {
        case release = "Release"
    }
    public struct Version_Subscript {
        var connection: Connection
        var statePath: StatePath
        public subscript(version:Version) -> String? {
            let l = Leaf<String>(connection: connection, component: .name("Version", name: version.rawValue), parentPath: statePath)
            return l.wrappedValue
        }
    }
    public var version:Version_Subscript { .init(connection: connection, statePath: statePath) }
    @Leaf public var blankStatsbookFound: Bool?

    

    @Leaf public var importsInProgress: Bool?

    public struct PenaltyCodes : PathNodeId, Identifiable {
        public var parent: ScoreBoard
        public var id: String? { String.from(component: statePath.last)?.1 }
        public let statePath: StatePath
        @ImmutableLeaf public var readonly: Bool?

        public typealias Code_Map = MapValueCollection<String, UUID>
        public var code:Code_Map { .init(connection: connection, statePath: self.adding(.wild("Code"))) }

        public typealias PenaltyCode_Map = MapValueCollection<String, UUID>
        public var penaltyCode:PenaltyCode_Map { .init(connection: connection, statePath: self.adding(.wild("PenaltyCode"))) }

        public init(parent: ScoreBoard, id: String) {
            self.parent = parent
            statePath = parent.adding(.name("PenaltyCodes", name: id))
    
            _readonly = parent.leaf("Readonly").immutable
            _readonly.parentPath = statePath
        }
        public init(parent: ScoreBoard, statePath: StatePath) {
            self.parent = parent
            self.statePath = statePath
            _readonly = parent.leaf("Readonly").immutable
            _readonly.parentPath = statePath
        }
    }
    public func penaltyCodes(_ id: String) -> PenaltyCodes { .init(parent: self, id: id) }
    public init(connection: Connection) {
        self.connection = connection
        let dummy = Leaf<Bool>(connection: connection, component: .wild(""), parentPath: .init(components: []))
        _blankStatsbookFound = dummy.leaf("BlankStatsbookFound")
        _importsInProgress = dummy.leaf("ImportsInProgress")
        _blankStatsbookFound.parentPath = statePath
        _importsInProgress.parentPath = statePath
    }
}
