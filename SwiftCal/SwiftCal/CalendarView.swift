//
//  CalendarView.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/10.
//

import CoreData
import SwiftUI

// MARK: - CalendarView

struct CalendarView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
    predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                           Date().startOfCalendarWithPrefixDays as CVarArg,
                           Date().endOfMonth as CVarArg),
    animation: .default
  )
  private var days: FetchedResults<Day>
  
  @State private var showAlert: Bool = false
  
  private let daysOfWeek: [String] = ["S", "M", "T", "W", "T", "F", "S"]
  
  var body: some View {
    NavigationView {
      VStack {
        HStack {
          ForEach(daysOfWeek, id: \.self) { dayOfWeek in
            Text(dayOfWeek)
              .fontWeight(.black)
              .foregroundStyle(.orange)
              .frame(maxWidth: .infinity)
          }
        }
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
          ForEach(days) { (day) in
            if day.date?.monthInt != Date().monthInt {
              Text(" ")
            } else {
              Text(day.date!.formatted(.dateTime.day()))
                .fontWeight(.bold)
                .foregroundStyle(day.didStudy ? .orange : .secondary)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(
                  Circle()
                    .foregroundStyle(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                )
                .onTapGesture {
                  if (day.date?.dayInt)! <= Date().dayInt {
                    day.didStudy.toggle()
                    
                    do {
                      try viewContext.save()
                    } catch {
                      print("Failed to save.")
                    }
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
      let day = Day(context: viewContext)
      day.date = Calendar.current.date(byAdding: .day, value: i, to: date.startOfMonth)
      day.didStudy = false
    }
    
    do {
      try viewContext.save()
    } catch {
      print("Failed to save.")
    }
  }
}

#Preview {
  CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
