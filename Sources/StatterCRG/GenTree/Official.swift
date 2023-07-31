// Official.swift
// Statter
//
// This file auto-generated by treemaker, do not edit
//

import Foundation
public struct Official : PathNodeId, Identifiable {
    public var parent: Game
    public var id: UUID? { UUID.from(component: statePath.last)?.1 }
    public let statePath: StatePath
    @ImmutableLeaf public var readonly: Bool?

    @Leaf public var role: String?

    @Leaf public var name: String?

    @Leaf public var league: String?

    @Leaf public var cert: String?

    @Leaf public var p1Team: UUID?

    @Leaf public var swap: Bool?

    public init(parent: Game, id: UUID) {
        self.parent = parent
        statePath = parent.adding(.id("Official", id: id))

        _readonly = parent.leaf("Readonly").immutable
        _role = parent.leaf("Role")
        _name = parent.leaf("Name")
        _league = parent.leaf("League")
        _cert = parent.leaf("Cert")
        _p1Team = parent.leaf("P1Team")
        _swap = parent.leaf("Swap")
        _readonly.parentPath = statePath
        _role.parentPath = statePath
        _name.parentPath = statePath
        _league.parentPath = statePath
        _cert.parentPath = statePath
        _p1Team.parentPath = statePath
        _swap.parentPath = statePath
    }
    public init(parent: Game, statePath: StatePath) {
        self.parent = parent
        self.statePath = statePath
        _readonly = parent.leaf("Readonly").immutable
        _role = parent.leaf("Role")
        _name = parent.leaf("Name")
        _league = parent.leaf("League")
        _cert = parent.leaf("Cert")
        _p1Team = parent.leaf("P1Team")
        _swap = parent.leaf("Swap")
        _readonly.parentPath = statePath
        _role.parentPath = statePath
        _name.parentPath = statePath
        _league.parentPath = statePath
        _cert.parentPath = statePath
        _p1Team.parentPath = statePath
        _swap.parentPath = statePath
    }
}
extension Game {
    public func nso(_ id: UUID) -> Official { .init(parent: self, id: id) }
}
extension Game {
    public func ref(_ id: UUID) -> Official { .init(parent: self, id: id) }
}
