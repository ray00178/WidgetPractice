//
//  RepoWatcherWidget.swift
//  RepoWatcherWidget
//
//  Created by Ray on 2023/8/28.
//

import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: TimelineProvider {
  func placeholder(in _: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), emoji: "😀")
  }

  func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), emoji: "😀")
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    var entries: [SimpleEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, emoji: "😀")
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

// MARK: - SimpleEntry

struct SimpleEntry: TimelineEntry {
  let date: Date
  let emoji: String
}

// MARK: - RepoWatcherWidgetEntryView

struct RepoWatcherWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    HStack {
      VStack {
        HStack {
          Circle()
            .fill(.orange)
            .frame(width: 50, height: 50)

          Text("EasyAlbum")
            .font(.title2)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        }
      }

      VStack {
        Text("99")
      }
    }
  }
}

// MARK: - RepoWatcherWidget

struct RepoWatcherWidget: Widget {
  let kind: String = "RepoWatcherWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        RepoWatcherWidgetEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        RepoWatcherWidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
    .supportedFamilies([.systemMedium])
    .contentMarginsDisabled()
  }
}

#Preview(as: .systemMedium) {
  RepoWatcherWidget()
} timeline: {
  SimpleEntry(date: .now, emoji: "😀")
  SimpleEntry(date: .now, emoji: "🤩")
}
