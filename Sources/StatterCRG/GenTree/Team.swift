// Team.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct Team : PathNodeId, Identifiable {
    public var parent: Game
    public var id: Int? { Int.from(component: statePath.last)?.1 }
    public let statePath: StatePath
    @Leaf public var team: Int?

    @Leaf public var name: String?

    @Leaf public var fullName: String?

    //    leaf AlternateName String

    @Leaf public var leagueName: String?

    // this is actually a map of ID -> String

    public typealias UniformColor_Map = MapValueCollection<String, UUID>
    public var uniformColor:UniformColor_Map { .init(connection: connection, statePath: self.adding(.wild("UniformColor"))) }

    //    leaf Color : String

    // A custom color for differnt roles

    public struct Color {
    public init(role: Team.AlternateName? = nil, component: Component) {
    self.role = role
    self.component = component
    }
    var role: Team.AlternateName?
    public enum Component : String {
    case fg
    case bg
    case glow
    }
    var component: Component
    var rawValue: String {
    if let role { return role.rawValue + "_" + component.rawValue }
    else { return component.rawValue }
    }
    }
    public struct Color_Subscript {
        var connection: Connection
        var statePath: StatePath
        public subscript(color:Color) -> String? {
            let l = Leaf<String>(connection: connection, component: .name("Color", name: color.rawValue), parentPath: statePath)
            return l.wrappedValue
        }
    }
    public var color:Color_Subscript { .init(connection: connection, statePath: statePath) }
    @Leaf public var score: Int?

    @Leaf public var timeouts: Int?

    @Leaf public var officialReviews: Int?

    @Flag public var retainedOfficialReview: Bool?

    @Leaf public var displayLead: Bool?

    @Leaf public var jamScore: Int?

    @Leaf public var noInitial: Bool?

    // path to file

    @Leaf public var logo: String?

    

    // these are lowercase

    public enum AlternateName: String, EnumStringAsID {
        case `operator` = "operator"
        case scoreboard = "scoreboard"
        case whiteboard = "whiteboard"
        case overlay = "overlay"
    }
    public struct AlternateName_Subscript {
        var connection: Connection
        var statePath: StatePath
        public subscript(alternateName:AlternateName) -> String? {
            let l = Leaf<String>(connection: connection, component: .name("AlternateName", name: alternateName.rawValue), parentPath: statePath)
            return l.wrappedValue
        }
    }
    public var alternateName:AlternateName_Subscript { .init(connection: connection, statePath: statePath) }
    @Flag public var timeout: Bool?

    @Flag public var officialReview: Bool?

    

    public var skaters : MapNodeCollection<Self, Skater> { .init(self,"Skater") } 

    public init(parent: Game, team: Int) {
        self.parent = parent
        statePath = parent.adding(.number("Team", param: team))

        _team = parent.leaf("Team")
        _name = parent.leaf("Name")
        _fullName = parent.leaf("FullName")
        _leagueName = parent.leaf("LeagueName")
        _score = parent.leaf("Score")
        _timeouts = parent.leaf("Timeouts")
        _officialReviews = parent.leaf("OfficialReviews")
        _retainedOfficialReview = parent.flag("RetainedOfficialReview")
        _displayLead = parent.leaf("DisplayLead")
        _jamScore = parent.leaf("JamScore")
        _noInitial = parent.leaf("NoInitial")
        _logo = parent.leaf("Logo")
        _timeout = parent.flag("Timeout")
        _officialReview = parent.flag("OfficialReview")
        _team.parentPath = statePath
        _name.parentPath = statePath
        _fullName.parentPath = statePath
        _leagueName.parentPath = statePath
        _score.parentPath = statePath
        _timeouts.parentPath = statePath
        _officialReviews.parentPath = statePath
        _retainedOfficialReview.parentPath = statePath
        _displayLead.parentPath = statePath
        _jamScore.parentPath = statePath
        _noInitial.parentPath = statePath
        _logo.parentPath = statePath
        _timeout.parentPath = statePath
        _officialReview.parentPath = statePath
    }
    public init(parent: Game, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _team = parent.leaf("Team")
        _name = parent.leaf("Name")
        _fullName = parent.leaf("FullName")
        _leagueName = parent.leaf("LeagueName")
        _score = parent.leaf("Score")
        _timeouts = parent.leaf("Timeouts")
        _officialReviews = parent.leaf("OfficialReviews")
        _retainedOfficialReview = parent.flag("RetainedOfficialReview")
        _displayLead = parent.leaf("DisplayLead")
        _jamScore = parent.leaf("JamScore")
        _noInitial = parent.leaf("NoInitial")
        _logo = parent.leaf("Logo")
        _timeout = parent.flag("Timeout")
        _officialReview = parent.flag("OfficialReview")
        _team.parentPath = statePath
        _name.parentPath = statePath
        _fullName.parentPath = statePath
        _leagueName.parentPath = statePath
        _score.parentPath = statePath
        _timeouts.parentPath = statePath
        _officialReviews.parentPath = statePath
        _retainedOfficialReview.parentPath = statePath
        _displayLead.parentPath = statePath
        _jamScore.parentPath = statePath
        _noInitial.parentPath = statePath
        _logo.parentPath = statePath
        _timeout.parentPath = statePath
        _officialReview.parentPath = statePath
    }
}
extension Game {
    public func team(_ team: Int) -> Team { .init(parent: self, team: team) }
}
