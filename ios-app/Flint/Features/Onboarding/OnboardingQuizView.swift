import SwiftUI
import FlintCore

struct QuizOption<Value: Hashable>: Identifiable {
    let value: Value
    let emoji: String
    let title: String
    var id: Value { value }
}

/// One quiz question. Single-select advances on tap; multi-select uses a sticky Continue.
struct QuizStepView<Value: Hashable>: View {
    let progress: Double
    let title: String
    let subtitle: String
    let options: [QuizOption<Value>]
    let isMultiSelect: Bool
    let isSelected: (Value) -> Bool
    let select: (Value) -> Void
    let canContinue: Bool
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        if isMultiSelect {
            content.nosStickyCTA("Continue", isEnabled: canContinue, action: onContinue)
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            NosProgressHeader(progress: progress, onBack: onBack)
                .padding(.horizontal, NosTheme.Spacing.gutter)
                .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .nosLargeTitle()
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 24)
                    Text(subtitle)
                        .nosSubtitle()
                        .padding(.bottom, 12)
                    ForEach(options) { option in
                        NosOptionCard(
                            emoji: option.emoji,
                            title: option.title,
                            isSelected: isSelected(option.value),
                            isMultiSelect: isMultiSelect
                        ) {
                            NosHaptics.tap()
                            select(option.value)
                            if !isMultiSelect {
                                // Let the selected state register before sliding on.
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 250_000_000)
                                    onContinue()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, NosTheme.Spacing.gutter)
                .padding(.bottom, 24)
            }
        }
        .background(NosTheme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - Question content (original copy)

enum OnboardingQuestions {
    static let screenTime: [QuizOption<FlintScreenTimeBucket>] = [
        QuizOption(value: .underTwo, emoji: "📱", title: "Under 2 hours"),
        QuizOption(value: .twoToFour, emoji: "⏱️", title: "2–4 hours"),
        QuizOption(value: .fourToSix, emoji: "😵‍💫", title: "4–6 hours"),
        QuizOption(value: .sixPlus, emoji: "🫠", title: "6+ hours"),
    ]

    static let pulls: [QuizOption<FlintPullCategory>] = [
        QuizOption(value: .social, emoji: "💬", title: "Social media"),
        QuizOption(value: .shortVideo, emoji: "🎬", title: "Short videos"),
        QuizOption(value: .games, emoji: "🎮", title: "Games"),
        QuizOption(value: .news, emoji: "📰", title: "News"),
        QuizOption(value: .shopping, emoji: "🛍️", title: "Shopping"),
        QuizOption(value: .messaging, emoji: "💌", title: "Messaging"),
    ]

    static let moments: [QuizOption<FlintScrollMoment>] = [
        QuizOption(value: .morning, emoji: "🌅", title: "First thing in the morning"),
        QuizOption(value: .workOrSchool, emoji: "💼", title: "At work or school"),
        QuizOption(value: .evening, emoji: "🛋️", title: "In the evening"),
        QuizOption(value: .bedtime, emoji: "🌙", title: "In bed before sleep"),
    ]

    static let goals: [QuizOption<FlintFocusGoal>] = [
        QuizOption(value: .sleep, emoji: "😴", title: "Better sleep"),
        QuizOption(value: .focus, emoji: "🎯", title: "Deeper focus"),
        QuizOption(value: .people, emoji: "👥", title: "Time with people"),
        QuizOption(value: .calm, emoji: "🧠", title: "A calmer mind"),
        QuizOption(value: .hobbies, emoji: "🎨", title: "Time for hobbies"),
    ]

    static let struggles: [QuizOption<FlintQuitStruggle>] = [
        QuizOption(value: .autopilot, emoji: "🤖", title: "I open apps on autopilot"),
        QuizOption(value: .fomo, emoji: "👀", title: "Fear of missing out"),
        QuizOption(value: .needPhoneForWork, emoji: "💼", title: "I need my phone for work"),
        QuizOption(value: .willpower, emoji: "🔋", title: "My willpower runs out"),
        QuizOption(value: .blockersTooEasy, emoji: "🔓", title: "Blockers are too easy to turn off"),
    ]
}
