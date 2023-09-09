//
//  Contributor.swift
//  RepoWatcher
//
//  Created by Ray on 2023/9/9.
//

import Foundation

struct Contributor: Decodable, Identifiable {
  
  let id: UUID = UUID()
  
  private(set) var userName: String
  
  private(set) var avatarUrl: String
    
  private(set) var contributions: Int
  
  var avatarData: Data
  
  private enum CodingKeys: String, CodingKey {
    case userName = "login"
    case avatarUrl = "avatar_url"
    case contributions = "contributions"
  }
  
  init(userName: String, avatarUrl: String, contributions: Int, avatarData: Data) {
    self.userName = userName
    self.avatarUrl = avatarUrl
    self.contributions = contributions
    self.avatarData = avatarData
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
    avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""
    contributions = try container.decodeIfPresent(Int.self, forKey: .contributions) ?? 0
    avatarData = Data()
  }
}
