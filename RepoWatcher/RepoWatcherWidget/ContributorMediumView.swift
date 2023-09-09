//
//  ContributorMediumView.swift
//  RepoWatcherWidgetExtension
//
//  Created by Ray on 2023/9/9.
//

import SwiftUI
import WidgetKit

// MARK: - ContributorMediumView

struct ContributorMediumView: View {
  let repo: Repository

  var body: some View {
    VStack {
      HStack {
        Text("Top Contributors")
          .font(.caption)
          .foregroundStyle(.secondary)
        Spacer()
      }

      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                alignment: .leading,
                spacing: 20)
      {
        ForEach(repo.contributors) { (contributor) in
          HStack {
            Image(uiImage: UIImage(data: contributor.avatarData) ?? UIImage(resource: .avatarPlaceholder))
              .resizable()
              .frame(width: 44, height: 44)
              .clipShape(Circle())

            VStack(alignment: .leading) {
              Text(contributor.userName)
                .font(.caption)
                .minimumScaleFactor(0.7)
              Text("\(contributor.contributions)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
      }
      
      if repo.contributors.count < 3 {
        Spacer()
          .frame(height: 20)
      }
    }
    .padding()
  }
}

// MARK: - ContributorMediumView_Previews

struct ContributorMediumView_Previews: PreviewProvider {
  static var previews: some View {
    if #available(iOS 17.0, *) {
      ContributorMediumView(repo: MockData.placeholder1)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(.white.gradient, for: .widget)
    } else {
      ContributorMediumView(repo: MockData.placeholder1)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
