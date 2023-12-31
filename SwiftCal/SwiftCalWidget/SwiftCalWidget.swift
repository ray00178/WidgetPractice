//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Ray on 2023/9/18.
//

import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: TimelineProvider {
  func placeholder(in _: Context) -> CalendarEntry {
    CalendarEntry(date: Date(), days: [])
  }

  @MainActor
  func getSnapshot(in _: Context, completion: @escaping (CalendarEntry) -> Void) {
    let entry = CalendarEntry(date: Date(), days: fetchDays())

    completion(entry)
  }

  @MainActor
  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let entry = CalendarEntry(date: Date(), days: fetchDays())
    let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))

    completion(timeline)
  }

  @MainActor
  func fetchDays() -> [Day] {
    let startDate: Date = .now.startOfCalendarWithPrefixDays
    let endDate: Date = .now.endOfMonth
    let predicate = #Predicate<Day> { $0.date > startDate && $0.date < endDate }
    let discriptor = FetchDescriptor<Day>(predicate: predicate, sortBy: [.init(\.date)])

    let context = ModelContext(Persistence.container)
    return try! context.fetch(discriptor)
  }
}

// MARK: - CalendarEntry

struct CalendarEntry: TimelineEntry {
  let date: Date
  let days: [Day]
}

// MARK: - SwiftCalWidgetEntryView

struct SwiftCalWidgetEntryView: View {
  @Environment(\.widgetFamily) var widgetFamily

  var entry: CalendarEntry

  var body: some View {
    switch widgetFamily {
    case .systemMedium:
      MediumCalendarView(entry: entry, streakValue: calculateStreakValue())
    case .accessoryInline:
      Label("Streak \(calculateStreakValue()) days", systemImage: "swift")
        .widgetURL(URL(string: "streak"))
    case .accessoryCircular:
      LockScreenCircularView(entry: entry)
    case .accessoryRectangular:
      LockScreenRectangularView(entry: entry)
    default:
      EmptyView()
    }
  }

  /// 計算連續study幾日
  func calculateStreakValue() -> Int {
    guard entry.days.isEmpty == false else { return 0 }

    let nonFutureDate = entry.days.filter { $0.date.dayInt <= Date().dayInt }

    var streakCount = 0

    for day in nonFutureDate.reversed() {
      if day.didStudy {
        streakCount += 1
      } else {
        if day.date.dayInt != Date().dayInt {
          break
        }
      }
    }

    return streakCount
  }
}

// MARK: - SwiftCalWidget

struct SwiftCalWidget: Widget {
  let kind: String = "SwiftCalWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        SwiftCalWidgetEntryView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        SwiftCalWidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Swift Study Calendar")
    .description("Track days you study Swift with streak.")
    .contentMarginsDisabled()
    .supportedFamilies([.systemMedium,
                        .accessoryInline,
                        .accessoryCircular,
                        .accessoryRectangular])
  }
}

#Preview(as: .systemMedium) {
  SwiftCalWidget()
} timeline: {
  CalendarEntry(date: .now, days: [])
}

#Preview(as: .accessoryRectangular) {
  SwiftCalWidget()
} timeline: {
  CalendarEntry(date: .now, days: [])
}

// MARK: - MediumCalendarView

private struct MediumCalendarView: View {
  var entry: CalendarEntry
  var streakValue: Int
  var columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)

  var today: Day {
    let day = entry.days.filter { Calendar.current.isDate($0.date, inSameDayAs: .now) }.first
    
    return day ?? .init(date: .distantPast, didStudy: false)
  }

  var body: some View {
    HStack {
      VStack {
        Link(destination: URL(string: "streak")!) {
          VStack {
            Text("\(streakValue)")
              .font(.system(size: 70, design: .rounded))
              .bold()
              .foregroundStyle(.orange)
              .contentTransition(.numericText())
            
            Text("day streak")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        .frame(width: 110)

        Button(today.didStudy ? "Studied" : "Study",
               systemImage: today.didStudy ? "checkmark.circle" : "book",
               intent: ToggleStudyIntent(date: today.date))
          .font(.callout)
          .tint(today.didStudy ? .mint : .orange)
          .controlSize(.small)
      }

      Link(destination: URL(string: "calendar")!) {
        VStack {
          CalendarHeaderView(font: .caption)

          LazyVGrid(columns: columns, spacing: 8) {
            ForEach(entry.days) { day in
              if day.date.monthInt != Date().monthInt {
                Text(" ")
              } else {
                Text(day.date.formatted(.dateTime.day()))
                  .font(.caption2)
                  .bold()
                  .frame(maxWidth: .infinity)
                  .foregroundStyle(day.didStudy ? .orange : .secondary)
                  .background {
                    Circle()
                      .foregroundStyle(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                      .scaleEffect(1.5)
                  }
              }
            }
          }
        }
      }
      .padding(.leading, 5)
    }
    .padding()
  }
}

// MARK: - LockScreenCircularView

private struct LockScreenCircularView: View {
  var entry: CalendarEntry

  var currentCalendarDays: Int {
    entry.days.filter { $0.date.monthInt == Date().monthInt }.count
  }

  var daysStudied: Int {
    entry.days.filter { $0.date.monthInt == Date().monthInt }
      .filter(\.didStudy)
      .count
  }

  var body: some View {
    Gauge(
      value: Double(daysStudied),
      in: 0 ... Double(currentCalendarDays),
      label: {
        Image(systemName: "swift")
      },
      currentValueLabel: {
        Text("\(daysStudied)")
      }
    )
    .gaugeStyle(.accessoryCircular)
  }
}

// MARK: - LockScreenRectangularView

private struct LockScreenRectangularView: View {
  var entry: CalendarEntry

  var columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 7)

  var body: some View {
    LazyVGrid(columns: columns, spacing: 4) {
      ForEach(entry.days) { day in
        if day.date.monthInt != Date().monthInt {
          Text(" ")
            .font(.system(size: 7))
        } else {
          if day.didStudy {
            Image(systemName: "swift")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 7, height: 7)
          } else {
            Text(day.date.formatted(.dateTime.day()))
              .font(.system(size: 7))
              .frame(maxWidth: .infinity)
          }
        }
      }
    }
  }
}
