//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/10.
//

import SwiftUI

@main
struct SwiftCalApp: App {
  let persistenceController = PersistenceController.shared

  init() {
    // Refrence = https://www.theswift.dev/posts/swiftui-alert-with-styled-buttons
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .orange
  }

  var body: some Scene {
    WindowGroup {
      TabView {
        CalendarView()
          .tabItem { Label("Calendar", systemImage: "calendar") }
        
        StreakView()
          .tabItem { Label("Streak", systemImage: "swift") }
      }
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
