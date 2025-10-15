import Foundation
import Testing
@testable import TimeSince25

final class RelativeTimeFormatterTests: TestCase {
    
    var formatter: RelativeTimeFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = RelativeTimeFormatter()
        // Deterministic reference date: 2024-01-01 12:00:00 UTC
        // We'll use timeIntervalSinceReferenceDate for calculations
    }

    func testZeroAndSmallPositiveSeconds() {
        // zero seconds
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 0), "now")
        // small positive seconds (< 60)
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 1), "1 second")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 30), "30 seconds")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 59), "59 seconds")
    }
    
    func testMinutesThresholds() {
        // 60 seconds = 1 minute
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 60), "1 minute")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 61), "1 minute")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 90), "1.5 minutes")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 119), "1.9 minutes")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 120), "2 minutes")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 3599), "59.9 minutes")
    }
    
    func testHoursThresholds() {
        // 3600 seconds = 1 hour
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 3600), "1 hour")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 5400), "1.5 hours")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 7199), "2 hours")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 86399), "23.9 hours")
    }
    
    func testDaysThresholds() {
        // 86400 seconds = 1 day
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 86400), "1 day")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 129600), "1.5 days")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 172799), "2 days")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 604799), "6.9 days")
    }
    
    func testWeeksThresholds() {
        // 604800 seconds = 1 week
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 604800), "1 week")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 907200), "1.5 weeks")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 1209599), "2 weeks")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 2591999), "4.9 weeks")
    }
    
    func testMonthsThresholds() {
        // Approximate month: 2629800 seconds (30.44 days)
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 2629800), "1 month")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 3944700), "1.5 months")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 5259600), "2 months")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 13149000), "5 months")
    }
    
    func testYearsThresholds() {
        // Approximate year: 31557600 seconds (365.25 days)
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 31557600), "1 year")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 47336400), "1.5 years")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 63115200), "2 years")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 157788000), "5 years")
    }
    
    func testDecimalFormattingOneFractionalDigit() {
        formatter.fractionDigits = 1
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 90), "1.5 minutes")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 5400), "1.5 hours")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 129600), "1.5 days")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 907200), "1.5 weeks")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 3944700), "1.5 months")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: 47336400), "1.5 years")
    }
    
    func testShowingRelativeFlagTrueFalse() {
        // Showing relative true (default)
        formatter.showingRelative = true
        XCTAssertTrue(formatter.localizedString(forTimeInterval: 60).contains("minute"))
        XCTAssertTrue(formatter.localizedString(forTimeInterval: 0).contains("now"))
        
        // Showing relative false
        formatter.showingRelative = false
        let positive = formatter.localizedString(forTimeInterval: 60)
        XCTAssertFalse(positive.contains("ago"))
        XCTAssertFalse(positive.contains("from now"))
        // It should just show "1 minute" or similar without relative suffix/prefix
    }
    
    func testNegativeDurationTreatedAsZero() {
        XCTAssertEqual(formatter.localizedString(forTimeInterval: -1), "now")
        XCTAssertEqual(formatter.localizedString(forTimeInterval: -1000), "now")
    }
    
    static var allTests = [
        ("testZeroAndSmallPositiveSeconds", testZeroAndSmallPositiveSeconds),
        ("testMinutesThresholds", testMinutesThresholds),
        ("testHoursThresholds", testHoursThresholds),
        ("testDaysThresholds", testDaysThresholds),
        ("testWeeksThresholds", testWeeksThresholds),
        ("testMonthsThresholds", testMonthsThresholds),
        ("testYearsThresholds", testYearsThresholds),
        ("testDecimalFormattingOneFractionalDigit", testDecimalFormattingOneFractionalDigit),
        ("testShowingRelativeFlagTrueFalse", testShowingRelativeFlagTrueFalse),
        ("testNegativeDurationTreatedAsZero", testNegativeDurationTreatedAsZero),
    ]
}
