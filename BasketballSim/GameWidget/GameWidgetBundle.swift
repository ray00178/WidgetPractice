//
//  GameWidgetBundle.swift
//  GameWidget
//
//  Created by Ray on 2023/11/18.
//

import SwiftUI
import WidgetKit

@main
struct GameWidgetBundle: WidgetBundle {
  var body: some Widget {
    GameWidget()
    
    if #available(iOS 16.1, *) {
      GameLiveActivity()
    }
    
  }
}
