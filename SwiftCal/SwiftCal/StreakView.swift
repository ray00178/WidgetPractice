//
//  StreakView.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/14.
//

import SwiftData
import SwiftUI

struct StreakView: View {
  
  @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate }, sort: \Day.date)
  var days: [Day]

  static var startDate: Date { .now.startOfCalendarWithPrefixDays }
  static var endDate: Date { .now.endOfMonth }

  @State private var streakValue = 0

  var body: some View {
    VStack {
      Text("\(streakValue)")
        .font(.system(size: 200, weight: .semibold, design: .rounded))
        .foregroundStyle(streakValue > 0 ? .orange : .pink)
      Text("Current Streak")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
    }
    .onAppear { streakValue = calculateStreakValue() }
  }

  /// 計算連續study幾日
  func calculateStreakValue() -> Int {
    guard days.isEmpty == false else { return 0 }

    let nonFutureDate = days.filter { $0.date.dayInt <= Date().dayInt }

    var streakCount = 0

    for day in nonFutureDate.reversed() {
      if day.didStudy {
        streakCount += 1
      } else {
        if day.date.dayInt != Date().dayInt {
          break
        }
      }
    }

    return streakCount
  }
}

#Preview {
  StreakView()
}
