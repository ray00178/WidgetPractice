//
//  CalendarView.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/10.
//

import SwiftData
import SwiftUI
import WidgetKit

// MARK: - CalendarView

struct CalendarView: View {
  @Environment(\.modelContext) private var context
  
  @Query(filter: #Predicate<Day> { $0.date > startDate && $0.date < endDate }, sort: \Day.date)
  var days: [Day]
  
  static var startDate: Date { .now.startOfCalendarWithPrefixDays }
  static var endDate: Date { .now.endOfMonth }
  
  @State private var showAlert: Bool = false
  
  private let daysOfWeek: [String] = ["S", "M", "T", "W", "T", "F", "S"]
  
  var body: some View {
    NavigationView {
      VStack {
        CalendarHeaderView()
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
          ForEach(days) { (day) in
            if day.date.monthInt != Date().monthInt {
              Text(" ")
            } else {
              Text(day.date.formatted(.dateTime.day()))
                .fontWeight(.bold)
                .foregroundStyle(day.didStudy ? .orange : .secondary)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(
                  Circle()
                    .foregroundStyle(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                )
                .onTapGesture {
                  if day.date.dayInt <= Date().dayInt {
                    day.didStudy.toggle()
                    
                    // Reload Widget
                    // See SwiftCalWidget to get kind string
                    WidgetCenter.shared.reloadTimelines(ofKind: "SwiftCalWidget")
                  } else {
                    showAlert = true
                  }
                }
                .alert("Oh, can't study in the future.", isPresented: $showAlert) {
                  Button("I Known", role: .cancel, action: {})
                    .tint(.orange)
                }
            }
          }
        }
        
        Spacer()
      }
      // defaultDigits = 9
      // narrow = S
      // wide = September
      // abbreviated = Sep
      // twoDigits = 09
      .navigationTitle(Date().formatted(.dateTime.month(.wide)))
      .padding()
      .onAppear {
        if days.isEmpty {
          createMonthDays(for: .now.startOfPreviousMonth)
          createMonthDays(for: .now)
        } 
        // Is this the prefix day
        else if days.count < 10 {
          createMonthDays(for: .now)
        }
      }
    }
  }
  
  func createMonthDays(for date: Date) {
    for i in 0 ..< date.numberOfDaysInMonth {
      let date = Calendar.current.date(byAdding: .day, value: i, to: date.startOfMonth)!
      let newDay = Day(date: date, didStudy: false)
      context.insert(newDay)
    }
  }
}

#Preview {
  CalendarView()
}
