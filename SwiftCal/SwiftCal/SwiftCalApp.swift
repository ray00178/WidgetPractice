//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/10.
//

import Security
import SwiftUI

// MARK: - SwiftCalApp

@main
struct SwiftCalApp: App {
  let persistenceController = PersistenceController.shared

  @State private var selectedTab: Int = 0

  init() {
    // Refrence = https://www.theswift.dev/posts/swiftui-alert-with-styled-buttons
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .orange
  }

  var body: some Scene {
    WindowGroup {
      TabView(selection: $selectedTab) {
        CalendarView()
          .tabItem { Label("Calendar", systemImage: "calendar") }
          .tag(0)

        StreakView()
          .tabItem { Label("Streak", systemImage: "swift") }
          .tag(1)
          
      }
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
      .onOpenURL { url in
        selectedTab = url.absoluteString == "calendar" ? 0 : 1
      }
      .onAppear {
        //addToKeychain(key: "secret", value: "123456")
        
        if let data = retrieveFromKeychain(key: "secret"),
           let value = String(data: data, encoding: .utf8) {
          print("retrieve = \(value)")
        } else {
          print("retrieve failure.")
        }
      }
    }
  }
}

extension SwiftCalApp {
  
  /// 儲存資料
  /// - Parameters:
  ///   - key: 資料金鑰
  ///   - value: 資料
  private func addToKeychain(key: String, value: String) {
    let attributes = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: "tw.midnight.SwiftCal",
      //kSecAttrAccessGroup: "yourteamid.tw.midnight.SwiftCal",
      kSecAttrAccount: key,
      kSecValueData: Data(value.utf8),
    ] as CFDictionary

    let status = SecItemAdd(attributes, nil)

    // Reference = https://developer.apple.com/documentation/security/1542001-security_framework_result_codes
    if status == errSecSuccess {
      print("Item added to Keychain successfully.")
    } else {
      print("Error adding item to Keychain: \(status)")
    }
  }

  /// 取得資料
  /// - Parameter key: 資料金鑰
  private func retrieveFromKeychain(key: String) -> Data? {
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: "tw.midnight.SwiftCal",
      //kSecAttrAccessGroup: "yourteamid.tw.midnight.SwiftCal",
      kSecAttrAccount: key,
      kSecReturnData: true,
      kSecReturnAttributes: true,
    ] as CFDictionary

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    if status == errSecSuccess {
      if let dictionary = item as? [String : Any],
         let data = dictionary[kSecValueData as String] as? Data {
        print("dictionary = \(dictionary)")
        return data
      } else {
        return nil
      }
    } else {
      print("Error retrieve item to Keychain: \(status)")
      return nil
    }
  }
}
