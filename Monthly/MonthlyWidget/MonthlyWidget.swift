//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Ray on 2023/8/26.
//

import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: IntentTimelineProvider {
  func placeholder(in _: Context) -> DayEntry {
    DayEntry(date: Date(), showFunFont: false)
  }

  func getSnapshot(for _: ChangeFontIntent, in _: Context, completion: @escaping (DayEntry) -> Void) {
    let entry = DayEntry(date: Date(), showFunFont: false)
    completion(entry)
  }

  func getTimeline(for configuration: ChangeFontIntent, in _: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
    var entries: [DayEntry] = []

    let showFunFont: Bool = configuration.funFont == 1

    // Generate a timeline consisting of seven entries a day apart, starting from the current date.
    let currentDate = Date()
    for dayOffset in 0 ..< 7 {
      let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
      let startDate = Calendar.current.startOfDay(for: entryDate)
      let entry = DayEntry(date: startDate, showFunFont: showFunFont)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

// MARK: - DayEntry

/* struct Provider: TimelineProvider {
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
 } */

struct DayEntry: TimelineEntry {
  let date: Date
  let showFunFont: Bool
}

// MARK: - MonthlyWidgetEntryView

struct MonthlyWidgetEntryView: View {
  @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
  @Environment(\.widgetRenderingMode) var rendingMode
  
  var entry: DayEntry
  var config: MonthConfig
  let funFontName: String = "Chalkduster"

  init(entry: DayEntry) {
    self.entry = entry
    config = MonthConfig.determineConfig(from: entry.date)
  }

  var body: some View {
    if #available(iOS 17.0, *) {
      calendarBody()
        .containerBackground(for: .widget) {
          ContainerRelativeShape()
            .fill(config.backgroundColor.gradient)
        }
    } else {
      ZStack {
        ContainerRelativeShape()
          .fill(config.backgroundColor.gradient)
        calendarBody()
          .padding()
      }
    }
  }

  @MainActor
  @ViewBuilder
  private func calendarBody() -> some View {
    VStack {
      HStack(spacing: 4) {
        Text(config.emoji)
          .font(.title)
        Text(entry.date.formatted(.dateTime.weekday(.wide)))
          .font(entry.showFunFont ? .custom(funFontName, size: 24) : .title3)
          .fontWeight(.bold)
          .minimumScaleFactor(0.6)
          .foregroundStyle(showsWidgetContainerBackground ? config.weekdayColor : .white)
        Spacer()
      }
      .id(entry.date)
      .transition(.push(from: .trailing))
      .animation(.bouncy, value: entry.date)

      Text(entry.date.formatted(.dateTime.day(.twoDigits)))
        .font(entry.showFunFont ? .custom(funFontName, size: 80) :
          .system(size: 80, weight: .heavy))
        .contentTransition(.numericText())
        .foregroundStyle(showsWidgetContainerBackground ? config.dayColor : .white)
    }
  }
}

// MARK: - MonthlyWidget

struct MonthlyWidget: Widget {
  let kind: String = "MonthlyWidget"

  var body: some WidgetConfiguration {
    IntentConfiguration(
      kind: kind,
      intent: ChangeFontIntent.self,
      provider: Provider()
    ) { entry in
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
    // 禁止哪些地方顯示Widget
    .disfavoredLocations([.lockScreen], for: [.systemSmall])
  }
}

#Preview(as: .systemSmall) {
  MonthlyWidget()
} timeline: {
  DayEntry(date: .now, showFunFont: false)
}
