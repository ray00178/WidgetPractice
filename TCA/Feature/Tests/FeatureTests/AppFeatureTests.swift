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
    )
    
    await store.send(.scenePhaseBecomeActive)
    await store.receive(.checkUserEnabledContentBlocker)
    await store.receive(.userEnabledContentBlocker(false))
  }
}
