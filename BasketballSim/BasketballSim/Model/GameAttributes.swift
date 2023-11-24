//
//  GameAttributes.swift
//  BasketballSim
//
//  Created by Ray on 2023/11/24.
//

import Foundation
import ActivityKit

// MARK: - GameAttributes

struct GameAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    // Dynamic stateful properties about your activity go here!
    var gameState: GameState
  }

  // Fixed non-changing properties about your activity go here!
  var homeTeam: String
  var awayTeam: String
}
