import ComposableArchitecture
@testable import Feature
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
  func testAppLaunch_userHavenEnableContentBlocker() async throws {
    // TCA 起手式
    let store = TestStore(
      initialState: AppFeature.State(),
      reducer: { AppFeature() }
    ) {
      $0.contentBlockerService.checkUserEnabledContentBlocker = { _ in false }
    }

    await store.send(.scenePhaseBecomeActive)
    await store.receive(.checkUserEnabledContentBlocker)
    await store.receive(.userEnabledContentBlocker(false))
  }

  func testAppLaunch_userAlreadyEnableContentBlocker() async throws {
    // TCA 起手式
    let store = TestStore(
      initialState: AppFeature.State(),
      reducer: { AppFeature() }
    ) {
      $0.contentBlockerService.checkUserEnabledContentBlocker = { _ in true }
    }

    await store.send(.scenePhaseBecomeActive)
    await store.receive(.checkUserEnabledContentBlocker)
    await store.receive(.userEnabledContentBlocker(true)) {
      $0.isEnabledContentBlocker = true
    }
  }

  func testAppLaunch_userHavenEnableContentBlocker_laterEnabled() async throws {
    // TCA 起手式
    let store = TestStore(
      initialState: AppFeature.State(),
      reducer: { AppFeature() }
    ) {
      $0.contentBlockerService.checkUserEnabledContentBlocker = { _ in false }
    }

    await store.send(.scenePhaseBecomeActive)
    await store.receive(.checkUserEnabledContentBlocker)
    await store.receive(.userEnabledContentBlocker(false))

    store.dependencies.contentBlockerService.checkUserEnabledContentBlocker = { _ in true }
    await store.send(.scenePhaseBecomeActive)
    await store.receive(.checkUserEnabledContentBlocker)
    await store.receive(.userEnabledContentBlocker(true)) {
      $0.isEnabledContentBlocker = true
    }
  }
}
