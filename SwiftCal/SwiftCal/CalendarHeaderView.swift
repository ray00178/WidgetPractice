//
//  CalendarHeaderView.swift
//  SwiftCal
//
//  Created by Ray on 2023/9/19.
//

import SwiftUI

struct CalendarHeaderView: View {
  
  private let daysOfWeek: [String] = ["S", "M", "T", "W", "T", "F", "S"]

  var font: Font = .body

  var body: some View {
    HStack {
      ForEach(daysOfWeek, id: \.self) { dayOfWeek in
        Text(dayOfWeek)
          .font(font)
          .fontWeight(.black)
          .foregroundStyle(.orange)
          .frame(maxWidth: .infinity)
      }
    }
  }
}

#Preview {
  CalendarHeaderView()
}
