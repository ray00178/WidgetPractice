//
//  Persistence.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/10.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  
  private let databaseName: String = "SwiftCal.sqlite"
  
  var oldStoreURL: URL {
    let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    return directory.appending(path: databaseName)
  }
  
  var shareStoreURL: URL {
    let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tw.midnight.SwiftCal")!
    return container.appending(path: databaseName)
  }
  
  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    
    guard let startDate = Calendar.current.dateInterval(of: .month, for: .now)?.start else {
      fatalError("Can't get start date.")
    }
    
    for i in 0 ..< 30 {
      let day = Day(context: viewContext)
      day.date = Calendar.current.date(byAdding: .day, value: i, to: startDate)
      day.didStudy = Bool.random()
    }
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "SwiftCal")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    else if FileManager.default.fileExists(atPath: oldStoreURL.path) == false {
      container.persistentStoreDescriptions.first!.url = shareStoreURL
    }
    
    print("Container URL = \(container.persistentStoreDescriptions.first!.url!)")
    
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    migrateStore(for: container)
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
  
  func migrateStore(for contianer: NSPersistentContainer) {
    print ("Went into migrateStore")
    let coodinator = contianer.persistentStoreCoordinator
    
    guard let oldStore = coodinator.persistentStore(for: oldStoreURL) else { return }
    print("Old store no longer exists")
    
    do {
      _ = try coodinator.migratePersistentStore(oldStore, to: shareStoreURL, type: .sqlite)
      print("Migration successful")
    } catch let error {
      fatalError("Unable to migrate share store \(error.localizedDescription)")
    }
    
    do {
      try FileManager.default.removeItem(at: oldStoreURL)
      print("Old store deleted")
    } catch let error {
      print("Unable to delete old store \(error.localizedDescription)")
    }
  }
}
