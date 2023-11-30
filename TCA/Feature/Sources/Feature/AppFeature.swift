import ComposableArchitecture
import ContentBlockerService
import SwiftUI

// MARK: - TCAApp

@main
struct TCAApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(store: Store(initialState: AppFeature.State(),
                           reducer: { AppFeature() })
      )
    }
  }
}

// MARK: - AppFeature

struct AppFeature: Reducer {
  struct State: Equatable {
    var isEnabledContentBlocker: Bool = false
  }

  enum Action: Equatable {
    case scenePhaseBecomeActive
    case checkUserEnabledContentBlocker
    case userEnabledContentBlocker(Bool)
  }

  @Dependency(\.contentBlockerService) var contentBlockerService

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .scenePhaseBecomeActive:
      return .send(.checkUserEnabledContentBlocker)

    case .checkUserEnabledContentBlocker:
      return .run { send in
        let isEnabled = await contentBlockerService.checkUserEnabledContentBlocker("BundleID")

        await send(.userEnabledContentBlocker(isEnabled))
      }

    case let .userEnabledContentBlocker(isEnabled):
      state.isEnabledContentBlocker = isEnabled
      return .none
    }
  }
}

// MARK: - AppView

struct AppView: View {
  @Environment(\.scenePhase) private var scenePhase

  let store: StoreOf<AppFeature>

  var body: some View {
    WithViewStore(store, observe: { $0.isEnabledContentBlocker }) { viewStore in
      let isEnabledContentBlocker = viewStore.state
      
      Text("Hello TCAApp = \(isEnabledContentBlocker ? "true" : "false")")
        .onChange(of: scenePhase) { _, newState in
          switch newState {
          case .active:
            store.send(.scenePhaseBecomeActive)
          case .inactive, .background:
            break
          @unknown default:
            break
          }
        }
    }
  }
}
