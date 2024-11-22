//
//  GameState.swift
//  ATLAS
//
//  Created by Savindu Wimalasooriya on 11/22/24.
//

import Foundation

// instead of using a singleton for this we can just store and pull data from firebase
class GameState {
    static let shared = GameState()

    private init() {}

    var unlockedAreas: [String: Bool] = ["Gregory Gymnasium": false, "Norman Hackerman": false, "Tower": false, "Fountain": false, "Union": false, "Engineering Building": false, "Blanton Museum": false, "Clock Knot": false]
}
