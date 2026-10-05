import SwiftUI
import FlintCore

/// First-run funnel: welcome → five questions → building → plan → Screen Time priming → paywall.
struct OnboardingFlow: View {
    let onFinish: () -> Void

    @EnvironmentObject private var entitlements: Entitlements
    @StateObject private var model = OnboardingModel()
    @StateObject private var auth = AuthorizationModel()

    var body: some View {
        ZStack {
            NosTheme.Colors.background.ignoresSafeArea()
            stepView
                .id(model.step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
        }
        .task { auth.refresh() }
    }

    @ViewBuilder private var stepView: some View {
        switch model.step {
        case .welcome:
            OnboardingWelcomeView { model.next() }

        case .screenTime:
            QuizStepView(
                progress: model.quizProgress,
                title: "How much time do you spend on your phone a day?",
                subtitle: "Your best guess is fine.",
                options: OnboardingQuestions.screenTime,
                isMultiSelect: false,
                isSelected: { model.answers.screenTime == $0 },
                select: { model.answers.screenTime = $0 },
                canContinue: model.canContinue,
                onBack: { model.back() },
                onContinue: { model.advance(from: .screenTime) }
            )

        case .pulls:
            QuizStepView(
                progress: model.quizProgress,
                title: "Which apps pull you in the most?",
                subtitle: "Pick all that apply.",
                options: OnboardingQuestions.pulls,
                isMultiSelect: true,
                isSelected: { model.answers.pulls.contains($0) },
                select: { model.toggle($0, in: \.pulls) },
                canContinue: model.canContinue,
                onBack: { model.back() },
                onContinue: { model.advance(from: .pulls) }
            )

        case .moments:
            QuizStepView(
                progress: model.quizProgress,
                title: "When do you scroll the most?",
                subtitle: "Pick all that apply.",
                options: OnboardingQuestions.moments,
                isMultiSelect: true,
                isSelected: { model.answers.moments.contains($0) },
                select: { model.toggle($0, in: \.moments) },
                canContinue: model.canContinue,
                onBack: { model.back() },
                onContinue: { model.advance(from: .moments) }
            )

        case .goals:
            QuizStepView(
                progress: model.quizProgress,
                title: "What do you want back?",
                subtitle: "Pick all that apply.",
                options: OnboardingQuestions.goals,
                isMultiSelect: true,
                isSelected: { model.answers.goals.contains($0) },
                select: { model.toggle($0, in: \.goals) },
                canContinue: model.canContinue,
                onBack: { model.back() },
                onContinue: { model.advance(from: .goals) }
            )

        case .struggles:
            QuizStepView(
                progress: model.quizProgress,
                title: "What's made cutting back hard?",
                subtitle: "This helps us pick the right strictness for you.",
                options: OnboardingQuestions.struggles,
                isMultiSelect: true,
                isSelected: { model.answers.struggles.contains($0) },
                select: { model.toggle($0, in: \.struggles) },
                canContinue: model.canContinue,
                onBack: { model.back() },
                onContinue: { model.advance(from: .struggles) }
            )

        case .building:
            OnboardingBuildingView { model.advance(from: .building) }

        case .plan:
            OnboardingPlanView(plan: model.plan) { model.next() }

        case .permission:
            ScreenTimePrimingView(auth: auth, onBack: { model.back() }, onFinish: afterPermission)

        case .paywall:
            PaywallView(onClose: finish)
        }
    }

    /// Pro users (e.g. replaying onboarding) skip the paywall.
    private func afterPermission() {
        if entitlements.isPro {
            finish()
        } else {
            model.advance(from: .permission)
        }
    }

    private func finish() {
        model.finish()
        onFinish()
    }
}

#Preview("Onboarding") {
    OnboardingFlow {}
        .environmentObject(Entitlements())
}
