//
//  APIManager.swift
//  RepoWatcher
//
//  Created by Ray on 2023/9/2.
//

import Foundation

class APIManager {
  
  static let shared: APIManager = .init()
  
  private let decoder: JSONDecoder = .init()
  
  private init() {
    decoder.dateDecodingStrategy = .iso8601
  }
}

extension APIManager {
  
  /// 取得Repository Info, https://api.github.com/repos/account{ray00178}/name{EasyAlbum}
  /// - Parameters:
  ///   - account: Account
  ///   - name: Repo Name
  /// - Returns: Repository
  public func fetchGithubRepoData(from account: String, name: String) async throws -> Repository {
    guard let url = URL(string: "https://api.github.com/repos/\(account)/\(name)")
    else {
      throw APIError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200
    else {
      throw APIError.invalidResponse
    }
    
    do {
      return try decoder.decode(Repository.self, from: data)
    } catch {
      throw APIError.parseFailure
    }
  }
  
  /// 取得大頭照Data
  /// - Parameter url: 大頭照URL
  /// - Returns: Data
  public func fetchAvatarData(from url: String) async -> Data {
    guard let url = URL(string: url)
    else {
      return Data()
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      return data
    } catch {
      return Data()
    }
  }
}

// MARK: - Enum

extension APIManager {
  
  enum APIError: Error {
    
    case invalidURL
    
    case invalidResponse
    
    case parseFailure
  }
  
}
