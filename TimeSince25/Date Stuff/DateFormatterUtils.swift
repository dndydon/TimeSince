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
  /// try:
  ///   Date.RelativeFormatStyle
  ///   let decimal: Decimal = 123456.789
  ///   let usStyle = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))
  ///   let frStyle = Decimal.FormatStyle(locale: Locale(identifier: "fr_FR"))
  ///   let formattedUS = decimal.formatted(usStyle) // 123,456.789
  ///   let formattedFR = decimal.formatted(frStyle) // 123 456,789
  ///
  ///   public enum UnitsStyle : Int, @unchecked Sendable {
  ///
  ///   case positional = 0
  ///
  ///   case abbreviated = 1
  ///
  ///   case short = 2
  ///
  ///   case full = 3
  ///
  ///   case spellOut = 4
  ///
  ///     @available(iOS 10.0, *)
  ///   case brief = 5
  ///   }
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

//// need to put this into Type name space and de-duplicate all the date stuff
//let itemFormatter: DateFormatter = {
//  let formatter = DateFormatter()
//  formatter.dateStyle = .short
//  formatter.timeStyle = .medium
//  return formatter
//}()

/// Global function
/// - Parameter time: TimeInterval
/// - Returns: a String using my modernFormat DateComponentsFormatter, above
func modernTimeIntervalString(_ time: TimeInterval) -> String {
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
