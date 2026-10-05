import SwiftUI

struct OnboardingWelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        NosScreen(alignment: .center, spacing: 0) {
            NosAppIcon(size: 96)
                .padding(.top, 48)

            (Text("no").foregroundColor(NosTheme.Colors.ink)
                + Text("Scroll").foregroundColor(NosTheme.Colors.accent))
                .font(.system(size: 40, weight: .heavy))
                .tracking(-1.5)
                .padding(.top, 20)

            Text("Put the phone down.")
                .nosLargeTitle()
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text("Answer five quick questions and we'll build a blocking plan around how you actually use your phone.")
                .nosSubtitle()
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            VStack(spacing: 16) {
                NosBenefitRow(tile: NosIconTile(symbol: "hand.raised.fill"), text: "Shield the apps that eat your day")
                NosBenefitRow(tile: NosIconTile(symbol: "calendar"), text: "Schedules that block on autopilot")
                NosBenefitRow(tile: NosIconTile(symbol: "lock.fill"), text: "Hardcore sessions you can't cancel")
            }
            .padding(.top, 36)
        }
        .nosStickyCTA(
            "Get started",
            finePrint: "No account needed. Your answers stay on this iPhone.",
            action: onStart
        )
    }
}

struct OnboardingBuildingView: View {
    let onDone: () -> Void

    @State private var progress = 0.0

    private struct Checkpoint: Hashable {
        let threshold: Double
        let text: String
    }

    private let checkpoints = [
        Checkpoint(threshold: 0.3, text: "Reading your answers"),
        Checkpoint(threshold: 0.6, text: "Setting a pace you can keep"),
        Checkpoint(threshold: 0.9, text: "Picking your first routine"),
    ]

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(NosTheme.Colors.accentSoft.opacity(0.4), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(NosTheme.accentGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.nosNumber(32))
                    .monospacedDigit()
                    .foregroundStyle(NosTheme.Colors.textPrimary)
            }
            .frame(width: 140, height: 140)

            Text("Building your plan")
                .nosLargeTitle()

            VStack(alignment: .leading, spacing: 14) {
                ForEach(checkpoints, id: \.self) { checkpoint in
                    let done = progress >= checkpoint.threshold
                    Label {
                        Text(checkpoint.text)
                            .font(.nosBody)
                            .foregroundStyle(done ? NosTheme.Colors.textPrimary : NosTheme.Colors.textSecondary)
                    } icon: {
                        Image(systemName: done ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(done ? NosTheme.Colors.accent : NosTheme.Colors.border)
                    }
                }
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, NosTheme.Spacing.gutter)
        .frame(maxWidth: .infinity)
        .background(NosTheme.Colors.background.ignoresSafeArea())
        .task {
            let steps = 40
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: 50_000_000)
                if Task.isCancelled { return }
                withAnimation(.linear(duration: 0.05)) { progress = Double(step) / Double(steps) }
            }
            NosHaptics.success()
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled { onDone() }
        }
    }
}

#Preview("Welcome") {
    OnboardingWelcomeView {}
}

#Preview("Building") {
    OnboardingBuildingView {}
}
