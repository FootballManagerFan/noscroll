import Foundation

// MARK: - Onboarding answers

/// "How much time do you spend on your phone a day?" — a self-estimate, not measured usage.
public enum FlintScreenTimeBucket: String, Codable, CaseIterable, Sendable {
    case underTwo
    case twoToFour
    case fourToSix
    case sixPlus

    /// Representative daily hours: the bucket midpoint, 7h for the open-ended top bucket.
    public var dailyHours: Double {
        switch self {
        case .underTwo: 1.5
        case .twoToFour: 3
        case .fourToSix: 5
        case .sixPlus: 7
        }
    }
}

public enum FlintPullCategory: String, Codable, CaseIterable, Sendable {
    case social, shortVideo, games, news, shopping, messaging
}

public enum FlintScrollMoment: String, Codable, CaseIterable, Sendable {
    case morning, workOrSchool, evening, bedtime
}

public enum FlintFocusGoal: String, Codable, CaseIterable, Sendable {
    case sleep, focus, people, calm, hobbies
}

public enum FlintQuitStruggle: String, Codable, CaseIterable, Sendable {
    case autopilot, fomo, needPhoneForWork, willpower, blockersTooEasy
}

public struct FlintOnboardingAnswers: Codable, Equatable, Sendable {
    public var screenTime: FlintScreenTimeBucket?
    public var pulls: Set<FlintPullCategory>
    public var moments: Set<FlintScrollMoment>
    public var goals: Set<FlintFocusGoal>
    public var struggles: Set<FlintQuitStruggle>

    public init(
        screenTime: FlintScreenTimeBucket? = nil,
        pulls: Set<FlintPullCategory> = [],
        moments: Set<FlintScrollMoment> = [],
        goals: Set<FlintFocusGoal> = [],
        struggles: Set<FlintQuitStruggle> = []
    ) {
        self.screenTime = screenTime
        self.pulls = pulls
        self.moments = moments
        self.goals = goals
        self.struggles = struggles
    }
}

// MARK: - Plan

/// The "your plan is ready" numbers, derived only from the user's own answers. Every figure is a
/// self-estimate projection and must be presented as one in the UI.
public struct FlintFocusPlan: Equatable, Sendable {
    /// Weeks to step down from today's estimate to the target.
    public static let weeks = 8
    /// Share of daily screen time the plan aims to cut.
    public static let reduction = 0.4
    /// The plan never targets less than this many hours a day.
    public static let floorHours = 1.0

    public let currentDailyHours: Double
    public let targetDailyHours: Double
    /// Daily-hours target at the start of each week: index 0 is today, the last is the target.
    public let weeklyTargets: [Double]
    public let targetDate: Date
    /// (current − target) × 365, rounded to the nearest 10.
    public let hoursBackPerYear: Int
    /// Whole-percent cut from current to target.
    public let percentCut: Int
    public let recommendedPreset: FlintRoutinePreset
    /// The user said blockers are too easy to switch off — point them at Hardcore.
    public let suggestsHardcore: Bool

    public init(answers: FlintOnboardingAnswers, startDate: Date = Date(), calendar: Calendar = .current) {
        let current = (answers.screenTime ?? .twoToFour).dailyHours
        let halfHourRounded = (current * (1 - Self.reduction) * 2).rounded() / 2
        let target = max(Self.floorHours, min(current, halfHourRounded))

        currentDailyHours = current
        targetDailyHours = target
        weeklyTargets = (0...Self.weeks).map { week in
            current - (current - target) * Double(week) / Double(Self.weeks)
        }
        let start = calendar.startOfDay(for: startDate)
        targetDate = calendar.date(byAdding: .weekOfYear, value: Self.weeks, to: start) ?? start
        hoursBackPerYear = Int(((current - target) * 365 / 10).rounded()) * 10
        percentCut = current > 0 ? Int(((1 - target / current) * 100).rounded()) : 0
        recommendedPreset = Self.recommendedPreset(for: answers)
        suggestsHardcore = answers.struggles.contains(.blockersTooEasy)
    }

    /// First match wins: night-time scrolling → evenings, work/study → work hours, feed apps →
    /// social detox; anything else → evenings, the gentlest all-round start.
    static func recommendedPreset(for answers: FlintOnboardingAnswers) -> FlintRoutinePreset {
        let name: String
        if !answers.moments.isDisjoint(with: [.evening, .bedtime]) {
            name = "Evenings offline"
        } else if answers.moments.contains(.workOrSchool) || answers.goals.contains(.focus) {
            name = "Work hours"
        } else if !answers.pulls.isDisjoint(with: [.social, .shortVideo]) {
            name = "Social detox"
        } else {
            name = "Evenings offline"
        }
        return FlintRoutinePreset.library.first { $0.name == name } ?? FlintRoutinePreset.library[0]
    }
}
