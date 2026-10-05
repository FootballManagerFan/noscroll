import SwiftUI

/// Store-facing values not known until billing and legal pages exist. Bracketed placeholders are
/// deliberate — they must be replaced (prices come from StoreKit products) before release.
enum PaywallConfig {
    static func price(for plan: ProPlan) -> String {
        switch plan {
        case .yearly: "[PRICE]/yr"
        case .weekly: "[PRICE]/wk"
        }
    }

    static func trial(for plan: ProPlan) -> String? {
        switch plan {
        case .yearly: "[TRIAL] free"
        case .weekly: nil
        }
    }

    static let termsURL: URL? = nil
    static let privacyURL: URL? = nil
}

struct PaywallView: View {
    let onClose: () -> Void

    @EnvironmentObject private var entitlements: Entitlements
    @State private var selected: ProPlan = .yearly
    @State private var isWorking = false
    @State private var errorText: String?

    var body: some View {
        NosScreen(alignment: .center, spacing: 18) {
            NosAppIcon(size: 72)
                .padding(.top, 36)

            Text("Make the block stick with Pro")
                .nosLargeTitle()
                .multilineTextAlignment(.center)

            VStack(spacing: 14) {
                NosBenefitRow(tile: NosIconTile(symbol: "lock.fill"), text: "Hardcore sessions you can't cancel")
                NosBenefitRow(tile: NosIconTile(symbol: "checklist"), text: "Allow List — block everything but what you need")
                NosBenefitRow(tile: NosIconTile(symbol: "key.fill"), text: "A weekly Emergency Pass for real emergencies")
                NosBenefitRow(tile: NosIconTile(symbol: "hand.tap.fill"), text: "Open Limits — cap how often apps open")
            }
            .padding(.vertical, 8)

            VStack(spacing: 12) {
                planCard(.yearly, title: "Yearly", badge: "Best value")
                planCard(.weekly, title: "Weekly", badge: nil)
            }

            if let errorText {
                Text(errorText)
                    .font(.nosCaption)
                    .foregroundStyle(NosTheme.Colors.danger)
                    .multilineTextAlignment(.center)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(NosTheme.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(NosTheme.Colors.surface))
                    .overlay(Circle().strokeBorder(NosTheme.Colors.border, lineWidth: 1))
            }
            .buttonStyle(NosPressableStyle())
            .accessibilityLabel("Close")
            .padding(.trailing, NosTheme.Spacing.gutter)
            .padding(.top, 8)
        }
        .nosStickyBar(background: NosTheme.Colors.surface, showsDivider: true) {
            if PaywallConfig.trial(for: selected) != nil {
                Label("No payment due now. Cancel anytime.", systemImage: "checkmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(NosTheme.Colors.textPrimary)
            }
            Button {
                Task { await buy() }
            } label: {
                if isWorking {
                    ProgressView().tint(.white)
                } else {
                    Text(PaywallConfig.trial(for: selected) != nil ? "Start free trial" : "Continue")
                }
            }
            .buttonStyle(.nosPrimary)
            .disabled(isWorking)

            Text(termsLine)
                .font(.nosCaption)
                .foregroundStyle(NosTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button("Restore Purchases") { Task { await restore() } }
                    .buttonStyle(NosTextButtonStyle(tint: NosTheme.Colors.textSecondary))
                legalLink("Terms", PaywallConfig.termsURL)
                legalLink("Privacy", PaywallConfig.privacyURL)
            }

            Button("Continue with free", action: onClose)
                .buttonStyle(.nosText)
        }
    }

    private var termsLine: String {
        let price = PaywallConfig.price(for: selected)
        if let trial = PaywallConfig.trial(for: selected) {
            return "\(trial), then \(price). Renews automatically until cancelled."
        }
        return "\(price). Renews automatically until cancelled."
    }

    private func planCard(_ plan: ProPlan, title: String, badge: String?) -> some View {
        let isSelected = selected == plan
        let shape = RoundedRectangle(cornerRadius: NosTheme.Radius.option, style: .continuous)
        return Button { selected = plan } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.nosHeadline)
                        .foregroundStyle(NosTheme.Colors.textPrimary)
                    Text(PaywallConfig.price(for: plan))
                        .font(.nosSubheadline)
                        .foregroundStyle(NosTheme.Colors.textSecondary)
                }
                Spacer()
                if let trial = PaywallConfig.trial(for: plan) {
                    Text(trial)
                        .font(.nosSubheadline.weight(.semibold))
                        .foregroundStyle(NosTheme.Colors.textSecondary)
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? NosTheme.Colors.accent : NosTheme.Colors.border)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(shape.fill(isSelected ? NosTheme.Colors.selectedFill : NosTheme.Colors.surface))
            .overlay(shape.strokeBorder(isSelected ? NosTheme.Colors.accent : NosTheme.Colors.border,
                                        lineWidth: isSelected ? 2 : 1))
            .overlay(alignment: .topTrailing) {
                if let badge {
                    NosBadge(badge)
                        .offset(x: -16, y: -11)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(NosPressableStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func legalLink(_ title: String, _ url: URL?) -> some View {
        if let url {
            Link(title, destination: url)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(NosTheme.Colors.textSecondary)
        } else {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(NosTheme.Colors.border)
        }
    }

    @MainActor
    private func buy() async {
        isWorking = true
        errorText = nil
        do {
            try await entitlements.purchase(selected)
            if entitlements.isPro {
                NosHaptics.success()
                onClose()
            }
        } catch {
            errorText = error.localizedDescription
        }
        isWorking = false
    }

    @MainActor
    private func restore() async {
        errorText = nil
        do {
            try await entitlements.restore()
            if entitlements.isPro {
                onClose()
            } else {
                errorText = "No active Pro subscription found."
            }
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview("Paywall") {
    PaywallView {}
        .environmentObject(Entitlements())
}
