//
//  MonthConfig.swift
//  MonthlyWidgetExtension
//
//  Created by Ray on 2023/8/27.
//

import SwiftUI

struct MonthConfig {
  let backgroundColor: Color
  let emoji: String
  let weekdayColor: Color
  let dayColor: Color

  static func determineConfig(from date: Date) -> MonthConfig {
    let month = Calendar.current.component(.month, from: date)

    switch month {
    case 1:
      return MonthConfig(backgroundColor: .gray,
                         emoji: "⛄️",
                         weekdayColor: .black.opacity(0.6),
                         dayColor: .white.opacity(0.8))
    case 2:
      return MonthConfig(backgroundColor: .palePink,
                         emoji: "❤️",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .pink.opacity(0.8))
    case 3:
      return MonthConfig(backgroundColor: .paleGreen,
                         emoji: "☘️",
                         weekdayColor: .black.opacity(0.7),
                         dayColor: .darkGreen.opacity(0.8))
    case 4:
      return MonthConfig(backgroundColor: .paleBlue,
                         emoji: "☔️",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .purple.opacity(0.8))
    case 5:
      return MonthConfig(backgroundColor: .paleYellow,
                         emoji: "🌺",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .pink.opacity(0.7))
    case 6:
      return MonthConfig(backgroundColor: .skyBlue,
                         emoji: "🌤",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .paleYellow.opacity(0.8))
    case 7:
      return MonthConfig(backgroundColor: .blue,
                         emoji: "🏖",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .paleBlue.opacity(0.8))
    case 8:
      return MonthConfig(backgroundColor: .paleOrange,
                         emoji: "☀️",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .darkOrange.opacity(0.8))
    case 9:
      return MonthConfig(backgroundColor: .paleRed,
                         emoji: "🍁",
                         weekdayColor: .black.opacity(0.5),
                         dayColor: .paleYellow.opacity(0.9))
    case 10:
      return MonthConfig(backgroundColor: .black,
                         emoji: "👻",
                         weekdayColor: .white.opacity(0.6),
                         dayColor: .orange.opacity(0.8))
    case 11:
      return MonthConfig(backgroundColor: .paleBrown,
                         emoji: "🦃",
                         weekdayColor: .black.opacity(0.6),
                         dayColor: .black.opacity(0.6))
    case 12:
      return MonthConfig(backgroundColor: .paleRed,
                         emoji: "🎄",
                         weekdayColor: .white.opacity(0.9),
                         dayColor: .darkGreen.opacity(0.7))
    default:
      return MonthConfig(backgroundColor: .gray,
                         emoji: "📅",
                         weekdayColor: .black.opacity(0.6),
                         dayColor: .white.opacity(0.8))
    }
  }
}
