import SwiftUI
import FlintCore

/// Drives the first-run funnel: quiz → plan → Screen Time priming → soft paywall. Answers stay on device in
/// standard `UserDefaults` (the extensions never need them).
@MainActor
final class OnboardingModel: ObservableObject {
    nonisolated static let completedKey = "ns.onboarding.completed"
    nonisolated static let answersKey = "ns.onboarding.answers"

    enum Step: Int, CaseIterable {
        case welcome, screenTime, pulls, moments, goals, struggles, building, plan, permission, paywall
    }

    @Published private(set) var step: Step = .welcome
    @Published var answers: FlintOnboardingAnswers

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.answersKey),
           let saved = try? JSONDecoder().decode(FlintOnboardingAnswers.self, from: data) {
            answers = saved
        } else {
            answers = FlintOnboardingAnswers()
        }
    }

    var plan: FlintFocusPlan { FlintFocusPlan(answers: answers) }

    /// Fill of the progress bar across the five quiz questions.
    var quizProgress: Double {
        let first = Step.screenTime.rawValue
        let last = Step.struggles.rawValue
        let position = min(max(step.rawValue - first + 1, 0), last - first + 1)
        return Double(position) / Double(last - first + 1)
    }

    var canContinue: Bool {
        switch step {
        case .screenTime: answers.screenTime != nil
        case .pulls: !answers.pulls.isEmpty
        case .moments: !answers.moments.isEmpty
        case .goals: !answers.goals.isEmpty
        case .struggles: !answers.struggles.isEmpty
        case .welcome, .building, .plan, .permission, .paywall: true
        }
    }

    func next() {
        guard let following = Step(rawValue: step.rawValue + 1) else { return }
        persistAnswers()
        withAnimation(.easeInOut(duration: 0.3)) { step = following }
    }

    /// Advance only if still on `expected` — a quick double tap on an auto-advancing question
    /// must not skip the next one.
    func advance(from expected: Step) {
        guard step == expected else { return }
        next()
    }

    func back() {
        var previous = Step(rawValue: step.rawValue - 1)
        // Never land back on the auto-advancing "building" interstitial.
        if previous == .building { previous = .struggles }
        guard let previous else { return }
        withAnimation(.easeInOut(duration: 0.3)) { step = previous }
    }

    func finish() {
        persistAnswers()
        defaults.set(true, forKey: Self.completedKey)
    }

    func toggle<T: Hashable>(_ value: T, in keyPath: WritableKeyPath<FlintOnboardingAnswers, Set<T>>) {
        if answers[keyPath: keyPath].contains(value) {
            answers[keyPath: keyPath].remove(value)
        } else {
            answers[keyPath: keyPath].insert(value)
        }
    }

    private func persistAnswers() {
        if let data = try? JSONEncoder().encode(answers) {
            defaults.set(data, forKey: Self.answersKey)
        }
    }
}

extension FlintFocusPlan {
    /// "3h", "2h 30m".
    static func formatHours(_ hours: Double) -> String {
        let totalMinutes = Int((hours * 60).rounded())
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if m == 0 { return "\(h)h" }
        if h == 0 { return "\(m)m" }
        return "\(h)h \(m)m"
    }
}
