//
//  RepoWatcherWidgetBundle.swift
//  CompactRepoWidget
//
//  Created by Ray on 2023/8/28.
//

import SwiftUI
import WidgetKit

@main
struct RepoWatcherWidgetBundle: WidgetBundle {
  var body: some Widget {
    CompactRepoWidget()
    ContributorWidget() 
  }
}
