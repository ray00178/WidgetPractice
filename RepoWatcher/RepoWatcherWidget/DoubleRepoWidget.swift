//
//  DoubleRepoWidget.swift
//  DoubleRepoWidget
//
//  Created by Ray on 2023/8/28.
//

import SwiftUI
import WidgetKit

// MARK: - DoubleRepoProvider

struct DoubleRepoProvider: IntentTimelineProvider {
  
  typealias Entry = DoubleRepoEntry
  
  typealias Intent = SelectTwoReposIntent
  
  func placeholder(in _: Context) -> DoubleRepoEntry {
    DoubleRepoEntry(date: Date(),
                    TopRepo: MockData.placeholder1,
                    bottomRepo: MockData.placeholder2)
  }
  
  func getSnapshot(for configuration: SelectTwoReposIntent, in context: Context, completion: @escaping (DoubleRepoEntry) -> Void) {
    let entry = DoubleRepoEntry(date: Date(),
                                TopRepo: MockData.placeholder1,
                                bottomRepo: MockData.placeholder2)
    completion(entry)
  }
  
  func getTimeline(for configuration: SelectTwoReposIntent, in context: Context, completion: @escaping (Timeline<DoubleRepoEntry>) -> Void) {
    Task(priority: .background) {
      // Every 30min update
      let nextUpdate = Date().addingTimeInterval(1800)

      do {
        // ray00178, EasyAlbum
        // onevcat, Kingfisher
        let topValues = configuration.topRepo!.components(separatedBy: "/")
        // Get Top Repo
        var repo = try await APIManager.shared.fetchGithubRepoData(from: topValues[0], name: topValues[1])
        let topAvatarData = await APIManager.shared.fetchAvatarData(from: repo.owner.avatarUrl)
        repo.avatarData = topAvatarData

        // Get Bottom Repo
        let bottomValues = configuration.bottomRepo!.components(separatedBy: "/")
        var bottomRepo = try await APIManager.shared.fetchGithubRepoData(from: bottomValues[0], name: bottomValues[1])

        let bottomAvatarData = await APIManager.shared.fetchAvatarData(from: bottomRepo.owner.avatarUrl)
        bottomRepo.avatarData = bottomAvatarData

        // Create Entry & Timeline
        let entry = DoubleRepoEntry(date: .now, TopRepo: repo, bottomRepo: bottomRepo)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
      } catch {
        print("API Error = \(error.localizedDescription)")
      }
    }
  }
  
  
}

// MARK: - DoubleRepoEntry

struct DoubleRepoEntry: TimelineEntry {
  let date: Date
  let TopRepo: Repository
  let bottomRepo: Repository
}

// MARK: - DoubleRepoEntryView

struct DoubleRepoEntryView: View {
  var entry: DoubleRepoEntry

  var body: some View {
    VStack(spacing: 36) {
      RepoWatcherMediumView(repo: entry.TopRepo)
      RepoWatcherMediumView(repo: entry.bottomRepo)
    }
  }
}

// MARK: - DoubleRepoWidget

struct DoubleRepoWidget: Widget {
  let kind: String = "DoubleRepoWidget"

  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: SelectTwoReposIntent.self, provider: DoubleRepoProvider()) { entry in
      if #available(iOS 17.0, *) {
        DoubleRepoEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        DoubleRepoEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("My Widget")
    .description("Keep an eye two GitHub repositories.")
    .supportedFamilies([.systemLarge])
    .contentMarginsDisabled()
    
    /*StaticConfiguration(kind: kind, provider: DoubleRepoProvider()) { entry in
      if #available(iOS 17.0, *) {
        DoubleRepoEntryView(entry: entry)
          .containerBackground(.white.gradient, for: .widget)
      } else {
        DoubleRepoEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("My Widget")
    .description("Keep an eye two GitHub repositories.")
    .supportedFamilies([.systemLarge])
    .contentMarginsDisabled()*/
  }
}

#Preview(as: .systemLarge) {
  DoubleRepoWidget()
} timeline: {
  DoubleRepoEntry(date: .now,
                  TopRepo: MockData.placeholder1,
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
