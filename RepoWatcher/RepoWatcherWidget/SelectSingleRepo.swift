//
//  SelectSingleRepo.swift
//  RepoWatcher
//
//  Created by Ray on 2023/12/9.
//

import AppIntents
import Foundation

struct SelectSingleRepo: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
  static let intentClassName = "SelectSingleRepoIntent"

  static var title: LocalizedStringResource = "Select Single Repo"
  static var description = IntentDescription("Choose a repository to watch")

  @Parameter(title: "Repo", optionsProvider: RepoOptionsProvider())
  var repo: String?

  struct RepoOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
      guard let repos = UserDefaults.shared.value(forKey: UserDefaults.repoKey) as? [String]
      else {
        throw UserDefaultsError.retrieval
      }
      return repos
    }

    func defaultResult() async -> String? {
      "ray00178/EasyAlbum"
    }
  }
}
