//
//  ContributorWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Ray on 2023/9/7.
//

import SwiftUI
import WidgetKit

// MARK: - ContributorPrivoder

struct ContributorPrivoder: TimelineProvider {
  func placeholder(in _: Context) -> ContributorEntry {
    ContributorEntry(date: .now)
  }

  func getSnapshot(in _: Context, completion: @escaping (ContributorEntry) -> Void) {
    let entry = ContributorEntry(date: .now)
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<ContributorEntry>) -> Void) {
    let nextUpdate = Date().addingTimeInterval(1800)
    let entry = ContributorEntry(date: .now)
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
}

// MARK: - ContributorEntry

struct ContributorEntry: TimelineEntry {
  var date: Date
}


struct ContributorEntryView: View {
  
  var entry: ContributorEntry

  var body: some View {
    Text(entry.date.formatted())
  }
}

struct ContributorWidget: Widget {
  let kind: String = "ContributorWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: ContributorPrivoder()) { entry in
      if #available(iOS 17.0, *) {
        ContributorEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        ContributorEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Contributor Widget")
    .description("This is an contributor widget.")
    .supportedFamilies([.systemLarge])
    .contentMarginsDisabled()
  }
}

#Preview(as: .systemLarge) {
  ContributorWidget()
} timeline: {
  ContributorEntry(date: .now)
}
