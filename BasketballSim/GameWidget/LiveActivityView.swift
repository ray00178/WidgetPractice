//
//  LiveActivityView.swift
//  GameWidgetExtension
//
//  Created by Ray on 2023/11/19.
//

import SwiftUI
import WidgetKit

// MARK: - LiveActivityView

struct LiveActivityView: View {
  var body: some View {
    ZStack {
      Image(.activityBackground)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .overlay {
          ContainerRelativeShape()
            .fill(.black.opacity(0.3).gradient)
        }

      VStack(spacing: 12) {
        HStack {
          Image(.warriors)
            .teamLogoModifier(frame: 60)

          Text("125")
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.white.opacity(0.8))

          Spacer()

          Text("60")
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.black.opacity(0.8))

          Image(.bulls)
            .teamLogoModifier(frame: 60)
        }
        
        HStack {
          Image(.warriors)
            .teamLogoModifier(frame: 20)
          
          Text("S. Curry drains a 3")
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(.white.opacity(0.9))
        }
      }
      .padding()
    }
  }
}

// MARK: - LiveActivityView_Preview

struct LiveActivityView_Preview: PreviewProvider {
  static var previews: some View {
    LiveActivityView()
      .previewContext(WidgetPreviewContext(family: .systemMedium))
      .containerBackground(.white.gradient, for: .widget)
  }
}
