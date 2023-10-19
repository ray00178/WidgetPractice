//
//  SingleRepoWidget.swift
//  RepoWatcherWidgetExtension
//
//  Created by Ray on 2023/9/7.
//

import SwiftUI
import WidgetKit

// MARK: - SingleRepoPrivoder

struct SingleRepoPrivoder: IntentTimelineProvider {
  typealias Entry = SingleRepoEntry
  
  typealias Intent = SelectSingleRepoIntent
  
  func placeholder(in _: Context) -> SingleRepoEntry {
    SingleRepoEntry(date: .now, repo: MockData.placeholder1)
  }
  
  func getSnapshot(for configuration: SelectSingleRepoIntent, in context: Context, completion: @escaping (SingleRepoEntry) -> Void) {
    let entry = SingleRepoEntry(date: .now, repo: MockData.placeholder1)
    completion(entry)
  }
  
  func getTimeline(for configuration: SelectSingleRepoIntent, in context: Context, completion: @escaping (Timeline<SingleRepoEntry>) -> Void) {
    Task {
      let nextUpdate = Date().addingTimeInterval(1800)

      do {
        // ray00178, EasyAlbum
        // onevcat, Kingfisher
        // configuration.repo = ray00178/EasyAlbum
        let values = configuration.repo!.components(separatedBy: "/")
        let user = values[0]
        let repoName = values[1]

        // Get Repo
        var repo = try await APIManager.shared.fetchGithubRepoData(from: user,
                                                                   name: repoName)
        let avatarData = await APIManager.shared.fetchAvatarData(from: repo.owner.avatarUrl)
        repo.avatarData = avatarData

        if context.family == .systemLarge {
          // Get Contributors
          var contributors = try await APIManager.shared.fetchContributorData(from: user,
                                                                              name: repoName)
          // Filter to just the top 4
          contributors = Array(contributors.prefix(4))

          // Download contributor avatar
          for i in contributors.indices {
            let avatarData = await APIManager.shared.fetchAvatarData(from: contributors[i].avatarUrl)
            contributors[i].avatarData = avatarData
          }

          repo.contributors = contributors
        }
        
        // Create Entry & Timeline
        let entry = SingleRepoEntry(date: .now, repo: repo)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
      } catch {
        print("API Error = \(error.localizedDescription)")
      }
    }
  }
}

// MARK: - SingleRepoEntry

struct SingleRepoEntry: TimelineEntry {
  var date: Date
  var repo: Repository
}

// MARK: - SingleRepoEntryView

struct SingleRepoEntryView: View {
  @Environment(\.widgetFamily) var widgetFamily
  var entry: SingleRepoEntry

  var body: some View {
    switch widgetFamily {
    case .systemMedium:
      RepoWatcherMediumView(repo: entry.repo)
    case .systemLarge:
      VStack {
        RepoWatcherMediumView(repo: entry.repo)
        ContributorMediumView(repo: entry.repo)
      }
    default:
      EmptyView()
    }
  }
}

// MARK: - SingleRepoWidget

struct SingleRepoWidget: Widget {
  let kind: String = "SingleRepoWidget"

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: SelectSingleRepoIntent.self, provider: SingleRepoPrivoder()) { entry in
      if #available(iOS 17.0, *) {
        SingleRepoEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        SingleRepoEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Single Repository Widget")
    .description("This is an contributor widget.")
    .supportedFamilies([.systemMedium, .systemLarge])
    .contentMarginsDisabled()
    
    /*StaticConfiguration(kind: kind, provider: SingleRepoPrivoder()) { entry in
      if #available(iOS 17.0, *) {
        SingleRepoEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        SingleRepoEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Single Repository Widget")
    .description("This is an contributor widget.")
    .supportedFamilies([.systemMedium, .systemLarge])
    .contentMarginsDisabled()*/
  }
}

#Preview(as: .systemMedium) {
  SingleRepoWidget()
} timeline: {
  SingleRepoEntry(date: .now, repo: MockData.placeholder1)
}

#Preview(as: .systemLarge) {
  SingleRepoWidget()
} timeline: {
  SingleRepoEntry(date: .now, repo: MockData.placeholder1)
}
