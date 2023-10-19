//
//  IntentHandler.swift
//  RepoWatcherIntents
//
//  Created by Ray on 2023/10/19.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler: SelectSingleRepoIntentHandling {

  func provideRepoOptionsCollection(for intent: SelectSingleRepoIntent) async throws -> INObjectCollection<NSString> {
    guard let repos = UserDefaults.shared.value(forKey: UserDefaults.repoKey) as? [String]
    else {
      throw UserDefaultsError.retrieval
    }
    
    return INObjectCollection(items: repos as [NSString])
  }
  
  /// 預設值
  /// - Parameter intent: SelectSingleRepoIntent
  /// - Returns: String 對應 SelectRepoIntents parameters
  func defaultRepo(for intent: SelectSingleRepoIntent) -> String? {
    return "ray00178/EasyAlbum"
  }
}

extension IntentHandler: SelectTwoReposIntentHandling {
  func provideTopRepoOptionsCollection(for intent: SelectTwoReposIntent) async throws -> INObjectCollection<NSString> {
    guard let repos = UserDefaults.shared.value(forKey: UserDefaults.repoKey) as? [String]
    else {
      throw UserDefaultsError.retrieval
    }
    
    return INObjectCollection(items: repos as [NSString])
  }
  
  func provideBottomRepoOptionsCollection(for intent: SelectTwoReposIntent) async throws -> INObjectCollection<NSString> {
    guard let repos = UserDefaults.shared.value(forKey: UserDefaults.repoKey) as? [String]
    else {
      throw UserDefaultsError.retrieval
    }
    
    return INObjectCollection(items: repos as [NSString])
  }
  
  func defaultTopRepo(for intent: SelectTwoReposIntent) -> String? {
    return "onevcat/Kingfisher"
  }
  
  func defaultBottomRepo(for intent: SelectTwoReposIntent) -> String? {
    return "apple/swift-book"
  }
}