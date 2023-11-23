import ComposableArchitecture
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
  struct State: Equatable {}

  enum Action: Equatable {
    case scenePhaseBecomeActive
    case checkUserEnabledContentBlocker
    case userEnabledContentBlocker(Bool)
  }

  func reduce(into _: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .scenePhaseBecomeActive:
      return .send(.checkUserEnabledContentBlocker)
    case .checkUserEnabledContentBlocker:
      return .send(.userEnabledContentBlocker(false))
    case let .userEnabledContentBlocker(bool):
      return .none
    }
  }
}

// MARK: - AppView

struct AppView: View {
  @Environment(\.scenePhase) private var scenePhase

  let store: StoreOf<AppFeature>

  var body: some View {
    Text("Hello TCAApp Yap")
      .onChange(of: scenePhase) { oldState, newState in
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
