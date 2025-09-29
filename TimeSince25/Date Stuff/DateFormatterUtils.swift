//
//  DateFormatterUtils.swift
//  SwiftMasterDetailCoreData
//
//  Created by Don Sleeter on 3/28/18.
//  Copyright © 2018 Don Sleeter. All rights reserved.
//

import Foundation


extension DateComponentsFormatter {
  /// I wish: DateComponentsFormatter.allowsFractionalUnits = true
  static let modernFormat: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.calendar = Calendar.autoupdatingCurrent
    formatter.unitsStyle = .abbreviated   //.brief  //.abbreviated
    formatter.includesApproximationPhrase = false
    formatter.includesTimeRemainingPhrase = false
    formatter.maximumUnitCount = 2
    formatter.zeroFormattingBehavior = .dropAll
    formatter.allowsFractionalUnits = true  // doesn't work
    formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
    return formatter
  }()
}


/// Global function
/// - Parameter time: TimeInterval
/// - Returns: a String using my modernFormat DateComponentsFormatter, above
@MainActor
public func modernTimeIntervalString(_ time: TimeInterval) -> String {
  let mf = DateComponentsFormatter.modernFormat.string(from: time)!
  return mf
}

class DateUtils: NSObject {
  public let dateFormatter: DateFormatter = {
    let myDateFormatter = DateFormatter()
    myDateFormatter.dateStyle = .short
    myDateFormatter.timeStyle = .short
    myDateFormatter.doesRelativeDateFormatting = true

    return myDateFormatter
  }()
}

extension Date {
  public func asDateTimeString() -> String {
    let formatter = DateUtils().dateFormatter
    let dateString = formatter.string(from: self)
    return dateString
  }
}
