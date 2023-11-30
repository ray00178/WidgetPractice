//
//  ContentBlockerServices.swift
//
//
//  Created by Ray on 2023/11/28.
//

import Dependencies
import SafariServices

// MARK: - ContentBlockerService

public struct ContentBlockerService {
  public var checkUserEnabledContentBlocker: (String) async -> Bool
}

// MARK: DependencyKey

extension ContentBlockerService: DependencyKey {
  public static var liveValue = ContentBlockerService { bundleID in
    await withCheckedContinuation { continuation in
      SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: bundleID) { state, error in
        if let error {
          // log...
        }

        if let state {
          continuation.resume(returning: state.isEnabled)
        } else {
          continuation.resume(returning: false)
        }
      }
    }
  }
}

// MARK: TestDependencyKey

extension ContentBlockerService: TestDependencyKey {
  public static var testValue = ContentBlockerService(
    checkUserEnabledContentBlocker: unimplemented("checkUserEnabledContentBlocker")
  )
}

public extension DependencyValues {
  var contentBlockerService: ContentBlockerService {
    get { self[ContentBlockerService.self] }
    set { self[ContentBlockerService.self] = newValue }
  }
}
