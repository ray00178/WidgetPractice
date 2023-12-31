//
//  Day.swift
//  SwiftCal
//
//  Created by Ray on 2023/12/30.
//
//

import Foundation
import SwiftData

@Model public class Day {
  var date: Date
  var didStudy: Bool

  init(date: Date, didStudy: Bool) {
    self.date = date
    self.didStudy = didStudy
  }
}
