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
    case .accessoryInline:
      Text("\(entry.repo.name) - \(entry.repo.daysSinceLastActivity) days")
    case .accessoryCircular:
      ZStack {
        AccessoryWidgetBackground()
        VStack {
          Text("\(entry.repo.daysSinceLastActivity)")
            .font(.headline)
          Text("days")
            .font(.caption)
        }
      }
    case .accessoryRectangular:
      VStack(alignment: .leading) {
        Text(entry.repo.name)
          .bold()
        Text("\(entry.repo.daysSinceLastActivity) days")
        
        HStack {
          StatLabel(value: entry.repo.watchers, systemImageName: "star.fill")
          StatLabel(value: entry.repo.forks, systemImageName: "tuningfork")

          if entry.repo.hasIssue {
            StatLabel(value: entry.repo.openIssues, systemImageName: "exclamationmark.triangle.fill")
          }
        }
        .font(.callout)
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
          .containerBackground(for: .widget) {}
      } else {
        SingleRepoEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Single Repository Widget")
    .description("This is an contributor widget.")
    .contentMarginsDisabled()
    .supportedFamilies([.systemMedium,
                        .systemLarge,
                        .accessoryInline,
                        .accessoryCircular,
                        .accessoryRectangular])
    
    
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
  SingleRepoEntry(date: .now, repo: MockData.placeholder2)
}

#Preview(as: .accessoryRectangular) {
  SingleRepoWidget()
} timeline: {
  SingleRepoEntry(date: .now, repo: MockData.placeholder1)
}
