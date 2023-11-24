//
//  GameLiveActivity.swift
//  GameWidget
//
//  Created by Ray on 2023/11/18.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - GameLiveActivity

struct GameLiveActivity: Widget {
  
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: GameAttributes.self) { context in
      // Lock screen/banner UI goes here
      LiveActivityView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded UI goes here.  Compose the expanded UI through
        // various regions, like leading/trailing/center/bottom
        DynamicIslandExpandedRegion(.leading) {
          HStack {
            Image(context.attributes.homeTeam)
              .teamLogoModifier(frame: 40)

            Text("\(context.state.gameState.homeScore)")
              .font(.title)
              .fontWeight(.semibold)
          }
        }
        DynamicIslandExpandedRegion(.trailing) {
          HStack {
            Text("\(context.state.gameState.awayScore)")
              .font(.title)
              .fontWeight(.semibold)

            Image(context.attributes.awayTeam)
              .teamLogoModifier(frame: 40)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          HStack {
            Image(context.state.gameState.scoringTeamName)
              .teamLogoModifier(frame: 20)
            
            Text(context.state.gameState.lastAction)
          }
        }
        DynamicIslandExpandedRegion(.center) {
          Text("5:24 3Q")
        }
      } compactLeading: {
        HStack {
          Image(context.attributes.homeTeam)
            .teamLogoModifier()

          Text("\(context.state.gameState.homeScore)")
            .fontWeight(.semibold)
        }
      } compactTrailing: {
        HStack {
          Text("\(context.state.gameState.awayScore)")
            .fontWeight(.semibold)

          Image(context.attributes.awayTeam)
            .teamLogoModifier()
        }
      } minimal: {
        Image(context.state.gameState.winningTeamName)
          .teamLogoModifier()
      }
      .widgetURL(URL(string: "http://www.apple.com"))
      .keylineTint(Color.red)
    }
  }
}

private extension GameAttributes {
  static var preview: GameAttributes {
    GameAttributes(homeTeam: "World", awayTeam: "Hello")
  }
}

private extension GameAttributes.ContentState {
  static var smiley: GameAttributes.ContentState {
    GameAttributes.ContentState(gameState: GameState.placehodler)
  }

  static var starEyes: GameAttributes.ContentState {
    GameAttributes.ContentState(gameState: GameState.placehodler)
  }
}

#Preview("Notification", as: .content, using: GameAttributes.preview) {
  GameLiveActivity()
} contentStates: {
  GameAttributes.ContentState.smiley
  GameAttributes.ContentState.starEyes
}
