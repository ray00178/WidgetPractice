//
//  Persistence.swift
//  SwiftCal
//
//  Created by Ray on 2024/1/1.
//

import SwiftData
import SwiftUI

struct Persistence {
  static var container: ModelContainer {
    
    let container: ModelContainer = {
      let shareStoreURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tw.midnight.SwiftCal")!.appending(path: "SwiftCal.sqlite")
      let config = ModelConfiguration(url: shareStoreURL)
      return try! ModelContainer(for: Day.self, configurations: config)
    }()
    
    return container
  }
}
