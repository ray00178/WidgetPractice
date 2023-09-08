//
//  RepoWatcherMediumView.swift
//  RepoWatcherWidgetExtension
//
//  Created by Ray on 2023/9/4.
//

import SwiftUI
import WidgetKit

// MARK: - RepoWatcherMediumView

struct RepoWatcherMediumView: View {
  private let formatter = ISO8601DateFormatter()
  
  let repo: Repository
  
  var diffDays: Int {
    calculateDaysSinceLastActivity(from: repo.pushedAt)
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        HStack {
          Image(uiImage: UIImage(data: repo.avatarData) ?? UIImage(resource: .avatarPlaceholder))
            .resizable()
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .circular))
            .overlay {
              RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.black.opacity(0.5), lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                .frame(width: 55, height: 55)
            }

          Text(repo.name)
            .font(.title2)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        }
        .padding(.bottom, 6)

        HStack {
          StatLabel(value: repo.watchers, systemImageName: "star.fill")
          StatLabel(value: repo.forks, systemImageName: "tuningfork")

          if repo.hasIssue {
            StatLabel(value: repo.openIssues, systemImageName: "exclamationmark.triangle.fill")
          }
        }
      }

      Spacer()

      VStack {
        Text("\(diffDays)")
          .bold()
          .font(.system(size: 70))
          .frame(width: 90)
          .minimumScaleFactor(0.6)
          .lineLimit(1)
          .foregroundStyle(diffDays > 50 ? .pink : .green)

        Text("days ago")
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
    }
    .padding()
  }

  func calculateDaysSinceLastActivity(from date: String) -> Int {
    let lastActivity = formatter.date(from: date) ?? .now
    let diffDays = Calendar.current.dateComponents([.day], from: lastActivity, to: .now).day ?? 0
    return diffDays
  }
}

// MARK: - RepoWatcherMediumView_Previews

struct RepoWatcherMediumView_Previews: PreviewProvider {
  static var previews: some View {
    if #available(iOS 17.0, *) {
      RepoWatcherMediumView(repo: MockData.placeholder1)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(.white.gradient, for: .widget)
    } else {
      RepoWatcherMediumView(repo: MockData.placeholder1)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
