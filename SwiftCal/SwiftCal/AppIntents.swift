//
//  AppIntents.swift
//  SwiftCal
//
//  Created by Ray on 2024/1/1.
//

import Foundation
import AppIntents
import SwiftData

struct ToggleStudyIntent: AppIntent {
  
  static var title: LocalizedStringResource = "Toggle Studied"
  
  @Parameter(title: "Date")
  var date: Date
  
  init() {}
  
  init(date: Date) {
    self.date = date
  }
  
  func perform() async throws -> some IntentResult {
    let context = ModelContext(Persistence.container)
    let predicate = #Predicate<Day> { $0.date == date }
    let discriptor = FetchDescriptor(predicate: predicate)
    
    guard let day = try context.fetch(discriptor).first else { return .result() }
    day.didStudy.toggle()
    
    do {
      try context.save()
    } catch let error {
      print("error = \(error)")
    }
    
    return .result()
  }
  
  
}
