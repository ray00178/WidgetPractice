//
//  GameModel.swift
//  BasketballSim
//
//  Created by Sean Allen on 11/6/22.
//

import ActivityKit
import Foundation

final class GameModel: ObservableObject, GameSimulatorDelegate {
  @Published var gameState = GameState(homeScore: 0,
                                       awayScore: 0,
                                       scoringTeamName: "",
                                       lastAction: "")

  var liveActivity: Activity<GameAttributes>? = nil

  let simulator = GameSimulator()

  init() {
    simulator.delegate = self
  }

  func didUpdate(gameState: GameState) {
    self.gameState = gameState

    Task {
      await liveActivity?.update(using: .init(gameState: gameState))
    }
  }

  func didCompleteGame() {
    Task {
      await liveActivity?.end(using: .init(gameState: simulator.endGame()), dismissalPolicy: .default)
    }
  }

  func startLiveActivity() {
    do {
      let attributes = GameAttributes(homeTeam: "warriors", awayTeam: "bulls")
      let currentGameState = GameAttributes.ContentState(gameState: gameState)

      // pushType = Use Remote Push Notification
      liveActivity = try Activity.request(attributes: attributes,
                                           content: .init(state: currentGameState, staleDate: nil))
    } catch {
      print(error.localizedDescription)
    }
  }
}
