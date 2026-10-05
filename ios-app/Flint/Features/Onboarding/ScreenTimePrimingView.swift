import SwiftUI
import FamilyControls

/// Explains the Screen Time prompt before iOS shows it, then triggers the real request. If the
/// request fails (always, in the Simulator) the user can retry or continue without access.
struct ScreenTimePrimingView: View {
    @ObservedObject var auth: AuthorizationModel
    let onBack: () -> Void
    let onFinish: () -> Void

    @State private var isRequesting = false
    @State private var didFail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NosProgressHeader(progress: 1, onBack: onBack)
                .padding(.horizontal, NosTheme.Spacing.gutter)
                .padding(.top, 8)

            NosScreen(spacing: 16) {
                Text("Let noScroll block distractions")
                    .nosLargeTitle()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
                Text("iOS will ask you to allow Screen Time access. That's what lets noScroll put a shield over the apps you pick.")
                    .nosSubtitle()
                    .fixedSize(horizontal: false, vertical: true)

                promptIllustration
                    .padding(.vertical, 8)

                NosBenefitRow(
                    tile: NosIconTile(symbol: "lock.shield.fill", fill: NosTheme.Colors.selectedFill),
                    text: "Your activity never leaves this iPhone. No account, no tracking."
                )

                if didFail {
                    failureCard
                }
            }
        }
        .background(NosTheme.Colors.background.ignoresSafeArea())
        .nosStickyBar {
            Button {
                Task { await request() }
            } label: {
                if isRequesting {
                    ProgressView().tint(.white)
                } else {
                    Text(didFail ? "Try again" : "Continue")
                }
            }
            .buttonStyle(.nosPrimary)
            .disabled(isRequesting)

            if didFail {
                Button("Continue without access", action: onFinish)
                    .buttonStyle(.nosText)
            }
        }
    }

    /// A non-interactive sketch of the system prompt so the real one isn't a surprise.
    private var promptIllustration: some View {
        VStack(spacing: 14) {
            Text("“noScroll” Would Like to Access Screen Time")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(NosTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            VStack(spacing: 8) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Capsule().fill(NosTheme.Colors.accent))
                Text("Don’t Allow")
                    .font(.system(size: 17))
                    .foregroundStyle(NosTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Capsule().fill(NosTheme.Colors.background))
            }
            Text("Tap Continue on the next screen")
                .font(.nosCaption)
                .foregroundStyle(NosTheme.Colors.accent)
        }
        .nosCard(padding: 20, alignment: .center)
        .padding(.horizontal, 24)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview of the Screen Time prompt. Tap Continue on the next screen.")
    }

    private var failureCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Screen Time access wasn't granted", systemImage: "exclamationmark.triangle.fill")
                .font(.nosHeadline)
                .foregroundStyle(NosTheme.Colors.textPrimary)
            Text(auth.lastError ?? "You can try again now, or turn it on later from the Focus tab. Blocking won't work until it's on.")
                .font(.nosCaption)
                .foregroundStyle(NosTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            #if targetEnvironment(simulator)
            Text("In the Simulator this always fails — Apple only grants Screen Time on a real iPhone.")
                .font(.nosCaption)
                .foregroundStyle(NosTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            #endif
        }
        .nosCard()
    }

    @MainActor
    private func request() async {
        isRequesting = true
        await auth.requestAuthorization()
        isRequesting = false
        if auth.status == .approved {
            NosHaptics.success()
            onFinish()
        } else {
            withAnimation { didFail = true }
        }
    }
}
