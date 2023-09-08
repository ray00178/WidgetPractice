//
//  CompactRepoWidget.swift
//  CompactRepoWidget
//
//  Created by Ray on 2023/8/28.
//

import SwiftUI
import WidgetKit

// MARK: - CompactRepoProvider

struct CompactRepoProvider: TimelineProvider {
  func placeholder(in _: Context) -> CompactRepoEntry {
    CompactRepoEntry(date: Date(),
              repo: MockData.placeholder1,
              bottomRepo: MockData.placeholder2)
  }

  func getSnapshot(in _: Context, completion: @escaping (CompactRepoEntry) -> Void) {
    let entry = CompactRepoEntry(date: Date(),
                          repo: MockData.placeholder1,
                          bottomRepo: MockData.placeholder2)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    Task(priority: .background) {
      // Every 30min update
      let nextUpdate = Date().addingTimeInterval(1800)

      do {
        // ray00178, EasyAlbum
        // onevcat, Kingfisher

        // Get Top Repo
        var repo = try await APIManager.shared.fetchGithubRepoData(from: "ray00178", name: "EasyAlbum")
        let avatarData = await APIManager.shared.fetchAvatarData(from: repo.owner.avatarUrl)
        repo.avatarData = avatarData

        // Get Bottom Repo if in large widget
        var bottomRepo: Repository?
        if context.family == .systemLarge {
          var temp = try await APIManager.shared.fetchGithubRepoData(from: "onevcat", name: "Kingfisher")

          let avatarData = await APIManager.shared.fetchAvatarData(from: temp.owner.avatarUrl)
          temp.avatarData = avatarData

          bottomRepo = temp
        }

        // Create Entry & Timeline
        let entry = CompactRepoEntry(date: .now, repo: repo, bottomRepo: bottomRepo)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
      } catch {
        print("API Error = \(error.localizedDescription)")
      }
    }
  }
}

// MARK: - CompactRepoEntry

struct CompactRepoEntry: TimelineEntry {
  let date: Date
  let repo: Repository
  let bottomRepo: Repository?
}

// MARK: - CompactRepoEntryView

struct CompactRepoEntryView: View {
  @Environment(\.widgetFamily) var widgetFamily

  var entry: CompactRepoEntry

  var body: some View {
    switch widgetFamily {
    case .systemMedium:
      RepoWatcherMediumView(repo: entry.repo)
    case .systemLarge:
      VStack(spacing: 36) {
        RepoWatcherMediumView(repo: entry.repo)

        if let repo = entry.bottomRepo {
          RepoWatcherMediumView(repo: repo)
        }
      }
    case .systemSmall, .systemExtraLarge,
         .accessoryCircular, .accessoryRectangular,
         .accessoryInline:
      EmptyView()
    @unknown default:
      EmptyView()
    }
  }
}

// MARK: - CompactRepoWidget

struct CompactRepoWidget: Widget {
  let kind: String = "CompactRepoWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: CompactRepoProvider()) { entry in
      if #available(iOS 17.0, *) {
        CompactRepoEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        CompactRepoEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
    .supportedFamilies([.systemMedium, .systemLarge])
    .contentMarginsDisabled()
  }
}

#Preview(as: .systemLarge) {
  CompactRepoWidget()
} timeline: {
  CompactRepoEntry(date: .now,
            repo: MockData.placeholder1,
            bottomRepo: MockData.placeholder2)
}

// MARK: - StatLabel

struct StatLabel: View {
  let value: Int
  let systemImageName: String

  var body: some View {
    Label(
      title: {
        Text("\(value)")
          .font(.footnote)
      },
      icon: {
        Image(systemName: systemImageName)
          .foregroundStyle(.green)
      }
    )
    .fontWeight(.medium)
  }
}
