//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Ray on 2023/9/18.
//

import CoreData
import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: TimelineProvider {
  var viewContext = PersistenceController.shared.container.viewContext

  var dayFetchRequest: NSFetchRequest<Day> {
    let request = Day.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
    request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)",
                                    Date().startOfCalendarWithPrefixDays as CVarArg,
                                    Date().endOfMonth as CVarArg)
    return request
  }

  func placeholder(in _: Context) -> CalendarEntry {
    CalendarEntry(date: Date(), days: [])
  }

  func getSnapshot(in _: Context, completion: @escaping (CalendarEntry) -> Void) {
    do {
      let days = try viewContext.fetch(dayFetchRequest)
      let entry = CalendarEntry(date: Date(), days: days)

      completion(entry)
    } catch {
      print("Widget failed to fetch days in snapshot. \(error.localizedDescription)")
    }
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    do {
      let days = try viewContext.fetch(dayFetchRequest)
      let entry = CalendarEntry(date: Date(), days: days)
      let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))

      completion(timeline)
    } catch {
      print("Widget failed to fetch days in timeline. \(error.localizedDescription)")
    }
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

    let nonFutureDate = entry.days.filter { $0.date!.dayInt <= Date().dayInt }

    var streakCount = 0

    for day in nonFutureDate.reversed() {
      if day.didStudy {
        streakCount += 1
      } else {
        if day.date!.dayInt != Date().dayInt {
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
          .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
      } else {
        SwiftCalWidgetEntryView(entry: entry)
          .padding()
          .background()
          .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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

  var body: some View {
    HStack {
      Link(destination: URL(string: "streak")!) {
        VStack {
          Text("\(streakValue)")
            .font(.system(size: 70, design: .rounded))
            .bold()
            .foregroundStyle(.orange)
          Text("day streak")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }

      Link(destination: URL(string: "calendar")!) {
        VStack {
          CalendarHeaderView(font: .caption)

          LazyVGrid(columns: columns, spacing: 8) {
            ForEach(entry.days) { day in
              if day.date!.monthInt != Date().monthInt {
                Text(" ")
              } else {
                Text(day.date!.formatted(.dateTime.day()))
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
    entry.days.filter { $0.date?.monthInt == Date().monthInt }.count
  }

  var daysStudied: Int {
    entry.days.filter { $0.date?.monthInt == Date().monthInt }
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
        if day.date!.monthInt != Date().monthInt {
          Text(" ")
            .font(.system(size: 7))
        } else {
          if day.didStudy {
            Image(systemName: "swift")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 7, height: 7)
          } else {
            Text(day.date!.formatted(.dateTime.day()))
              .font(.system(size: 7))
              .frame(maxWidth: .infinity)
          }
        }
      }
    }
  }
}
