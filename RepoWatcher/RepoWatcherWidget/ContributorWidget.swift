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
    ContributorEntry(date: .now, repo: MockData.placeholder1)
  }

  func getSnapshot(in _: Context, completion: @escaping (ContributorEntry) -> Void) {
    let entry = ContributorEntry(date: .now, repo: MockData.placeholder1)
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<ContributorEntry>) -> Void) {
    Task {
      let nextUpdate = Date().addingTimeInterval(1800)

      do {
        // ray00178, EasyAlbum
        // onevcat, Kingfisher
        
        let user: String = "ray00178"
        let repoName: String = "EasyAlbum"
        
        // Get Repo
        var repo = try await APIManager.shared.fetchGithubRepoData(from: user,
                                                                   name: repoName)
        let avatarData = await APIManager.shared.fetchAvatarData(from: repo.owner.avatarUrl)
        repo.avatarData = avatarData

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
        
        // Create Entry & Timeline
        let entry = ContributorEntry(date: .now, repo: repo)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
      } catch {
        print("API Error = \(error.localizedDescription)")
      }
    }
  }
}

// MARK: - ContributorEntry

struct ContributorEntry: TimelineEntry {
  var date: Date
  var repo: Repository
}

// MARK: - ContributorEntryView

struct ContributorEntryView: View {
  var entry: ContributorEntry

  var body: some View {
    VStack {
      RepoWatcherMediumView(repo: entry.repo)
      ContributorMediumView(repo: entry.repo)
    }
  }
}

// MARK: - ContributorWidget

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
  ContributorEntry(date: .now, repo: MockData.placeholder1)
}
