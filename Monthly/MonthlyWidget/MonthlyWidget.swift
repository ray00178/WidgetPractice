//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Ray on 2023/8/26.
//

import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: TimelineProvider {
  func placeholder(in _: Context) -> DayEntry {
    DayEntry(date: Date())
  }

  func getSnapshot(in _: Context, completion: @escaping (DayEntry) -> Void) {
    let entry = DayEntry(date: Date())
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    var entries: [DayEntry] = []

    // Generate a timeline consisting of seven entries a day apart, starting from the current date.
    let currentDate = Date()
    for dayOffset in 0 ..< 7 {
      let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
      let startDate = Calendar.current.startOfDay(for: entryDate)
      let entry = DayEntry(date: startDate)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

// MARK: - DayEntry

struct DayEntry: TimelineEntry {
  let date: Date
}

// MARK: - MonthlyWidgetEntryView

struct MonthlyWidgetEntryView: View {
  var entry: DayEntry
  var config: MonthConfig
  
  init(entry: DayEntry) {
    self.entry = entry
    self.config = MonthConfig.determineConfig(from: entry.date)
  }
  
  var body: some View {
    ZStack {
      ContainerRelativeShape()
        .fill(config.backgroundColor.gradient)

      VStack {
        HStack(spacing: 4) {
          Text(config.emoji)
            .font(.title)
          Text(entry.date.formatted(.dateTime.weekday(.wide)))
            .font(.title3)
            .fontWeight(.bold)
            .minimumScaleFactor(0.6)
            .foregroundColor(config.weekdayColor)
          Spacer()
        }

        Text(entry.date.formatted(.dateTime.day(.twoDigits)))
          .font(.system(size: 80, weight: .heavy))
          .foregroundStyle(config.dayColor)
      }
      .padding()
    }
  }
}

// MARK: - MonthlyWidget

struct MonthlyWidget: Widget {
  let kind: String = "MonthlyWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        MonthlyWidgetEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        MonthlyWidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Monthly Style Widget")
    .description("The theme of the widget changes base on month.")
    .supportedFamilies([.systemSmall])
    // iOS 17 later 主要用來取消預設padding
    // Reference = https://shorturl.at/diAIR
    .contentMarginsDisabled()
  }
}

#Preview(as: .systemSmall) {
  MonthlyWidget()
} timeline: {
  DayEntry(date: .now)
  DayEntry(date: .now)
}
