import SwiftUI
import Charts
import FlintCore

struct OnboardingPlanView: View {
    let plan: FlintFocusPlan
    let onContinue: () -> Void

    private var targetText: String { FlintFocusPlan.formatHours(plan.targetDailyHours) }
    private var currentText: String { FlintFocusPlan.formatHours(plan.currentDailyHours) }

    var body: some View {
        NosScreen(alignment: .center, spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Circle().fill(NosTheme.Colors.ink))
                .padding(.top, 16)
                .accessibilityHidden(true)

            Text("Your plan is ready")
                .nosLargeTitle()
                .multilineTextAlignment(.center)

            Text("A pace built from your answers — steady enough to stick.")
                .nosSubtitle()
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            targetCard
            chartCard

            NosStatCard(
                tile: NosIconTile(emoji: "⏳", fill: NosTheme.Colors.selectedFill),
                value: "~\(plan.hoursBackPerYear) hrs",
                label: "back each year, by your estimate"
            )

            routineCard
        }
        .nosStickyCTA("Let's do this", action: onContinue)
    }

    private var targetCard: some View {
        VStack(spacing: 10) {
            Text("Get under \(targetText) a day by")
                .font(.nosHeadline)
                .foregroundStyle(NosTheme.Colors.textPrimary)
            HStack(spacing: 12) {
                NosIconTile(emoji: "📅", size: 48, fill: NosTheme.Colors.selectedFill)
                Text(plan.targetDate.formatted(.dateTime.month(.wide).day()))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(NosTheme.Colors.accent)
            }
        }
        .nosCard(padding: 20, alignment: .center)
        .accessibilityElement(children: .combine)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your daily screen time")
                .font(.nosHeadline)
                .foregroundStyle(NosTheme.Colors.textPrimary)
            Text("\(currentText) now → \(targetText) in \(FlintFocusPlan.weeks) weeks · \(plan.percentCut)% less")
                .font(.nosCaption)
                .foregroundStyle(NosTheme.Colors.textSecondary)

            Chart {
                ForEach(Array(plan.weeklyTargets.enumerated()), id: \.offset) { item in
                    BarMark(
                        x: .value("Week", weekLabel(item.offset)),
                        y: .value("Hours", item.element)
                    )
                    .foregroundStyle(item.offset == 0 ? NosTheme.Colors.accentSoft : NosTheme.Colors.accent)
                    .cornerRadius(6)
                }
                RuleMark(y: .value("Target", plan.targetDailyHours))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(NosTheme.Colors.textSecondary)
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                        }
                    }
                }
            }
            .frame(height: 180)
            .accessibilityLabel("Daily screen time stepping down from \(currentText) to \(targetText) over \(FlintFocusPlan.weeks) weeks")
        }
        .nosCard(padding: 20)
    }

    private var routineCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your first routine").nosEyebrow()
            HStack(spacing: 12) {
                NosIconTile(symbol: "calendar.badge.clock", size: 48, fill: NosTheme.Colors.selectedFill)
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.recommendedPreset.name)
                        .font(.nosHeadline)
                        .foregroundStyle(NosTheme.Colors.textPrimary)
                    Text(plan.recommendedPreset.description)
                        .font(.nosCaption)
                        .foregroundStyle(NosTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if plan.suggestsHardcore {
                Label("You said blockers are too easy to turn off — try a Hardcore session. Once it starts, it can't be cancelled.",
                      systemImage: "lock.fill")
                    .font(.nosCaption)
                    .foregroundStyle(NosTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
            Text("Add it any time from the Schedules tab.")
                .font(.nosCaption)
                .foregroundStyle(NosTheme.Colors.textSecondary)
        }
        .nosCard(padding: 20)
    }

    private func weekLabel(_ week: Int) -> String {
        week == 0 ? "Now" : "W\(week)"
    }
}

#Preview("Plan ready") {
    OnboardingPlanView(
        plan: FlintFocusPlan(answers: FlintOnboardingAnswers(
            screenTime: .fourToSix,
            moments: [.bedtime],
            struggles: [.blockersTooEasy]
        ))
    ) {}
}
