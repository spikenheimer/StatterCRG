//
//  SB.swift
//  Statter
//
//  Created by gandreas on 7/22/23.
//

import SwiftUI
import StatterCRG


public struct TeamNameLogo : View {
    public init(team: Team) {
        self.team = team
    }
    
    @EnvironmentObject var connection: Connection
    @Environment(\.teamNameLogoStyle) var style
    var team: Team
    public var body: some View {
//        Text(team.name ?? team.uniformColor ?? "Team \(team.team)")
//            .font(.largeTitle)
        style.body(for: team)
    }
}

public enum TimeoutDot {
    case unused
    case used
    case retained
}

public struct Timeouts : View {
    public init(team: Team) {
        self.team = team
    }
    
    @EnvironmentObject var connection: Connection
    @EnvironmentObject var theme: Theme
    var team: Team
    #if nomore
    @ViewBuilder var timeoutView: some View {
        VStack {
            ForEach(0..<3) {
                if $0 < (team.timeouts ?? 0) {
                    theme.timeout.view(for: TimeoutDot.unused)
                } else {
                    theme.timeout.view(for: TimeoutDot.used)
                }
            }
            .foregroundColor(.backgroundFill)
        }
    }
    @ViewBuilder var officialReviewView: some View {
        if let officialReviews = team.officialReviews, officialReviews > 0 {
            if team.retainedOfficialReview == true {
                theme.timeout.view(for: TimeoutDot.retained)
            } else {
                theme.timeout.view(for: TimeoutDot.unused)
            }
        } else {
            theme.timeout.view(for: TimeoutDot.used)
        }

    }
    struct TimeoutBox<C:View> : View {
        @EnvironmentObject var theme: Theme
        var content: C
        init(@ViewBuilder content: ()->C) {
            self.content = content()
        }
        var body: some View {
            content
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: theme.timeout.cornerRadius)
                )
        }
    }
    public var body: some View {
        if theme.timeout.separateBoxes {
            VStack {
                TimeoutBox {
                    timeoutView
                }
                TimeoutBox {
                    officialReviewView
                }
            }
        } else {
            TimeoutBox {
                VStack {
                    timeoutView
//                    Divider().frame(width: 16)
//                        .foregroundColor(.black)
                    Rectangle().frame(width: 16, height: 1)
                        .foregroundColor(.primary)
                    officialReviewView
                }
            }
        }
    }
    #else
    @Environment(\.timeoutStyle) var timeoutStyle
    struct AnyTimeoutStyleView<TS:TimeoutStyle> : View {
        var ts: TS
        var team: Team
        var body: some View {
            ts.body(for: team)
        }
    }
    public var body: some View {
//        AnyTimeoutStyleView(ts: timeoutStyle, team: team)
        timeoutStyle.body(for: team)
    }
    #endif
}

public struct TimeDisplay : View {
    public init(game: Game) {
        self.game = game
    }
    
    @EnvironmentObject var connection: Connection
    var game: Game
    public var body: some View {
        if game.intermissionClock.running == true {
            Text("Intermission \(game.intermissionClock.time.timeValue)")
        } else if game.timeOutClock.running == true || game.lineupClock.running == true {
            HStack {
                Text(game.periodClock.time.timeValue)
                if let period = game.currentPeriodNumber {
                    Text("P\(period)")
                    Text("J\(game.period(period).currentJamNumber ?? 0)")
                }
            }
            HStack {
                if game.lineupClock.running == true {
                    Text("Lineup")
                    Text(game.lineupClock.time.timeValue)
                } else {
                    Text(game.officialReview == true ? "OR" : "TO")
                    Text(game.timeOutClock.time.timeValue)
                }
            }
        } else if let period = game.currentPeriodNumber {
            #if os(watchOS)
            HStack { Text("Period \(period)")
                Spacer()
                Text(game.periodClock.time.timeValue)
            }
            HStack { Text("Jam \(game.period(period).currentJamNumber ?? 0)")
                Spacer()
                Text(game.jamClock.time.timeValue)
            }
            #else
            GroupBox("Period \(period)") {
                Text(game.periodClock.time.timeValue)
            }
            GroupBox("Jam \(game.period(period).currentJamNumber ?? 0)") {
                Text(game.jamClock.time.timeValue)
            }
            #endif
        }

    }
}

public struct SB: View {
    @EnvironmentObject var theme: Theme

    public init(game: Game) {
        self.game = game
    }
    
    public struct TeamDisplay : View {
        public init(team: Team, leftSide: Bool, showJammer: Bool) {
            self.team = team
            self.leftSide = leftSide
            self.showJammer = showJammer
        }
        
        @EnvironmentObject var connection: Connection
        var team: Team
        var leftSide: Bool
        var showJammer: Bool
        public var body: some View {
            VStack {
                TeamNameLogo(team: team)
                    .font(.largeTitle)
                HStack {
                    FlipGroup(if: !leftSide) {
                        Timeouts(team: team)
                        Spacer()
                        Text("\(team.score ?? 0)")
                            .font(.largeTitle)
                        Spacer()
                        Text("\(team.jamScore ?? 0)")
                    }
                }
                if showJammer && team.displayLead == true {
                    Text("Lead")
                } else {
                    Text("")
                }
            }
        }
    }
    @EnvironmentObject var connection: Connection
    var game: Game
    
    #if os(watchOS)
    public var body: some View {
        List {
            VStack(alignment: .center) {
                TimeDisplay(game: game)
            }
            TeamDisplay(team: game.teamOne, leftSide: false, showJammer: game.inJam == true)
            TeamDisplay(team: game.teamTwo, leftSide: false, showJammer: game.inJam == true)
        }
        .listStyle(.carousel)
    }
    #else
    public var body: some View {
        VStack {
            HStack {
                TeamDisplay(team: game.teamOne, leftSide: true, showJammer: game.inJam == true)
                Divider()
                TeamDisplay(team: game.teamTwo, leftSide: false, showJammer: game.inJam == true)
            }
            Divider()
            HStack {
                TimeDisplay(game: game)
            }
        }
    }
    #endif
}

