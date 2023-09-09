//
//  Repository.swift
//  RepoWatcher
//
//  Created by Ray on 2023/8/31.
//

import Foundation

struct Repository: Decodable {
  
  let name: String
  let owner: Owner
  let hasIssue: Bool
  let forks: Int
  let watchers: Int
  let openIssues: Int
  let pushedAt: String
  var avatarData: Data
  var contributors: [Contributor] = []

  private enum CodingKeys: String, CodingKey {
    case name = "name"
    case owner = "owner"
    case hasIssue = "has_issue"
    case forks = "forks"
    case watchers = "watchers"
    case openIssues = "open_issues"
    case pushedAt = "pushed_at"
  }
  
  init(name: String, 
       owner: Owner,
       hasIssue: Bool,
       forks: Int,
       watchers: Int,
       openIssues: Int,
       pushedAt: String,
       avatarData: Data,
       contributors: [Contributor]) {
    self.name = name
    self.owner = owner
    self.hasIssue = hasIssue
    self.forks = forks
    self.watchers = watchers
    self.openIssues = openIssues
    self.pushedAt = pushedAt
    self.avatarData = avatarData
    self.contributors = contributors
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    
    if let value = try container.decodeIfPresent(Owner.self, forKey: .owner) {
      owner = value
    } else {
      owner = Owner()
    }
    
    hasIssue = try container.decodeIfPresent(Bool.self, forKey: .hasIssue) == true
    forks = try container.decodeIfPresent(Int.self, forKey: .forks) ?? 0
    watchers = try container.decodeIfPresent(Int.self, forKey: .watchers) ?? 0
    openIssues = try container.decodeIfPresent(Int.self, forKey: .openIssues) ?? 0
    pushedAt = try container.decodeIfPresent(String.self, forKey: .pushedAt) ?? ""
    avatarData = Data()
  }
}

struct Owner: Decodable {
  
  /// 照片 Url
  private(set) var avatarUrl: String
  
  private enum CodingKeys: String, CodingKey {
    case avatarUrl = "avatar_url"
  }
  
  init() {
    avatarUrl = "https://avatars.githubusercontent.com/u/16967982?v=4"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""
  }
}
