//
//  ContentView.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/10.
//

import CoreData
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
    animation: .default
  )
  
  private var days: FetchedResults<Day>

  var body: some View {
    NavigationView {
      List {
        ForEach(days) { day in
          Text("Day at \(day.date!.formatted())")
        }
      }
    }
  }
}

#Preview {
  ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
