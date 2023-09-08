//
//  MockData.swift
//  RepoWatcherWidgetExtension
//
//  Created by Ray on 2023/9/7.
//

import Foundation

struct MockData {
  
  static let placeholder1: Repository = .init(name: "SwiftUI 1",
                                              owner: Owner(),
                                              hasIssue: true,
                                              forks: 100,
                                              watchers: 898,
                                              openIssues: 10,
                                              pushedAt: "2023-08-30T22:14:00Z",
                                              avatarData: Data())

  static let placeholder2: Repository = .init(name: "SwiftUI 2",
                                              owner: Owner(),
                                              hasIssue: false,
                                              forks: 99,
                                              watchers: 10,
                                              openIssues: 5,
                                              pushedAt: "2023-01-30T22:14:00Z",
                                              avatarData: Data())
}
