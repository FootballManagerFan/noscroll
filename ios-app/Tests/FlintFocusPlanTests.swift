import XCTest
import FlintCore

/// Onboarding plan math: every number on the "plan ready" screen comes from here, so pin the
/// bucket → target → projection chain and the routine recommendation.
final class FlintFocusPlanTests: XCTestCase {

    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func plan(_ answers: FlintOnboardingAnswers) -> FlintFocusPlan {
        FlintFocusPlan(answers: answers, startDate: Date(timeIntervalSince1970: 1_790_000_000), calendar: utc)
    }

    func testTargetsCutFortyPercentToTheNearestHalfHour() {
        let expected: [FlintScreenTimeBucket: Double] = [
            .underTwo: 1.0,   // 0.9 → 1.0 (also the floor)
            .twoToFour: 2.0,  // 1.8 → 2.0
            .fourToSix: 3.0,  // 3.0
            .sixPlus: 4.0,    // 4.2 → 4.0
        ]
        for (bucket, target) in expected {
            XCTAssertEqual(plan(.init(screenTime: bucket)).targetDailyHours, target, "\(bucket)")
        }
    }

    func testTargetNeverDropsBelowTheFloorOrAboveCurrent() {
        for bucket in FlintScreenTimeBucket.allCases {
            let p = plan(.init(screenTime: bucket))
            XCTAssertGreaterThanOrEqual(p.targetDailyHours, FlintFocusPlan.floorHours)
            XCTAssertLessThanOrEqual(p.targetDailyHours, p.currentDailyHours)
        }
    }

    func testUnansweredScreenTimeFallsBackToTwoToFourHours() {
        XCTAssertEqual(plan(.init()).currentDailyHours, FlintScreenTimeBucket.twoToFour.dailyHours)
    }

    func testWeeklyTargetsStepDownFromCurrentToTarget() {
        let p = plan(.init(screenTime: .sixPlus))
        XCTAssertEqual(p.weeklyTargets.count, FlintFocusPlan.weeks + 1)
        XCTAssertEqual(p.weeklyTargets.first, p.currentDailyHours)
        XCTAssertEqual(p.weeklyTargets.last!, p.targetDailyHours, accuracy: 1e-9)
        for (earlier, later) in zip(p.weeklyTargets, p.weeklyTargets.dropFirst()) {
            XCTAssertLessThan(later, earlier)
        }
    }

    func testProjectionsAreRoundedEstimates() {
        let p = plan(.init(screenTime: .fourToSix)) // 5h → 3h
        XCTAssertEqual(p.hoursBackPerYear, 730)
        XCTAssertEqual(p.percentCut, 40)
        XCTAssertEqual(p.hoursBackPerYear % 10, 0)
    }

    func testTargetDateIsEightWeeksFromTheStartOfToday() {
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        let p = plan(.init(screenTime: .twoToFour))
        let expected = utc.date(byAdding: .day, value: 56, to: utc.startOfDay(for: start))
        XCTAssertEqual(p.targetDate, expected)
    }

    func testRecommendationPrefersNightThenWorkThenFeeds() {
        XCTAssertEqual(
            plan(.init(pulls: [.social], moments: [.bedtime, .workOrSchool])).recommendedPreset.name,
            "Evenings offline"
        )
        XCTAssertEqual(plan(.init(moments: [.workOrSchool])).recommendedPreset.name, "Work hours")
        XCTAssertEqual(plan(.init(goals: [.focus])).recommendedPreset.name, "Work hours")
        XCTAssertEqual(plan(.init(pulls: [.shortVideo])).recommendedPreset.name, "Social detox")
        XCTAssertEqual(plan(.init(pulls: [.games])).recommendedPreset.name, "Evenings offline")
    }

    func testEveryRecommendationResolvesToALibraryPreset() {
        let names = Set(FlintRoutinePreset.library.map(\.name))
        for moment in FlintScrollMoment.allCases {
            XCTAssertTrue(names.contains(plan(.init(moments: [moment])).recommendedPreset.name))
        }
    }

    func testHardcoreIsSuggestedOnlyWhenBlockersFeelTooEasy() {
        XCTAssertTrue(plan(.init(struggles: [.blockersTooEasy, .fomo])).suggestsHardcore)
        XCTAssertFalse(plan(.init(struggles: [.autopilot, .willpower])).suggestsHardcore)
    }

    func testAnswersRoundTripThroughCodable() throws {
        let answers = FlintOnboardingAnswers(
            screenTime: .fourToSix,
            pulls: [.social, .news],
            moments: [.bedtime],
            goals: [.sleep],
            struggles: [.blockersTooEasy]
        )
        let decoded = try JSONDecoder().decode(
            FlintOnboardingAnswers.self,
            from: JSONEncoder().encode(answers)
        )
        XCTAssertEqual(decoded, answers)
    }
}
