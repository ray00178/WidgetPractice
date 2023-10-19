//
//  UserDefaults+Extension.swift
//  RepoWatcher
//
//  Created by Ray on 2023/9/29.
//

import Foundation

extension UserDefaults {
  
  static var shared: UserDefaults {
    UserDefaults(suiteName: "group.tw.midnight.RepoWatcher")!
  }
  
  static let repoKey: String = "repos"
}

enum UserDefaultsError: Error {
  
  case retrieval
}
