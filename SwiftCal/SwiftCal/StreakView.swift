//
//  StreakView.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/14.
//

import SwiftUI
import CoreData

struct StreakView: View {
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
    predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                           Date().startOfMonth as CVarArg,
                           Date().endOfMonth as CVarArg),
    animation: .default
  )
  private var days: FetchedResults<Day>
  
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
    guard days.isEmpty == false else { return 0}
    
    let nonFutureDate = days.filter { $0.date!.dayInt <= Date().dayInt }
    
    var streakCount = 0
    
    for day in nonFutureDate.reversed() {
      if day.didStudy {
        streakCount += 1
      } else {
        if day.date!.dayInt != Date().dayInt {
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
