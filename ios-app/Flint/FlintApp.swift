import SwiftUI
import FlintCore

@main
struct FlintApp: App {
    init() {
        NosTheme.applyChromeAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Top-level shell: first-run onboarding, then an optional app-PIN gate, then the tabs.
struct RootView: View {
    @AppStorage(OnboardingModel.completedKey) private var onboardingCompleted = false
    @State private var locked = FlintPIN.isSet(FlintGroupStore())
    @StateObject private var entitlements = Entitlements()

    var body: some View {
        shell.environmentObject(entitlements)
    }

    @ViewBuilder private var shell: some View {
        if !onboardingCompleted {
            OnboardingFlow { onboardingCompleted = true }
        } else if locked {
            PINGateView { locked = false }
        } else {
            TabView {
                ContentView()
                    .tabItem { Label("Focus", systemImage: "flame.fill") }
                SchedulesView()
                    .tabItem { Label("Schedules", systemImage: "calendar") }
                LimitsView()
                    .tabItem { Label("Limits", systemImage: "hourglass") }
                StatsView()
                    .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
            .tint(FlintBrand.spark)
            .task {
                // Re-arm Open-Limit shields (+ their day-boundary activities) on every launch —
                // that's what puts tokens released by yesterday's grants back behind the shield.
                // Schedules/Time Limits re-arm in their tab view models; Open Limits' screen sits
                // a level deeper, so its view model may never init in a given run.
                FlintOpenLimitsController().reload()
                // Reconcile the Hardcore uninstall guard with reality on every launch:
                // re-assert it while a Hardcore session is still running, drop it if the
                // session ended while Flint was dead (e.g. the monitor never got to fire).
                FlintSessionController().reconcileUninstallGuard()
            }
        }
    }
}

struct PINGateView: View {
    let onUnlock: () -> Void
    @State private var pin = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            NosAppIcon(size: 80)
            Text("Enter your PIN")
                .nosLargeTitle()
                .padding(.top, 8)
            Text("noScroll is locked.")
                .nosSubtitle()
            SecureField("PIN", text: $pin)
                .keyboardType(.numberPad)
                .font(.nosNumber(28))
                .multilineTextAlignment(.center)
                .frame(width: 200, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: NosTheme.Radius.option, style: .continuous)
                        .fill(NosTheme.Colors.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: NosTheme.Radius.option, style: .continuous)
                        .strokeBorder(showError ? NosTheme.Colors.danger : NosTheme.Colors.border, lineWidth: 1)
                )
                .padding(.top, 8)
            if showError {
                Text("Incorrect PIN")
                    .font(.nosCaption)
                    .foregroundStyle(NosTheme.Colors.danger)
            }
            Spacer()
            Button("Unlock", action: unlock)
                .buttonStyle(.nosPrimary)
                .disabled(pin.isEmpty)
        }
        .padding(.horizontal, NosTheme.Spacing.gutter)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(NosTheme.Colors.background.ignoresSafeArea())
    }

    private func unlock() {
        if FlintPIN.verify(pin, FlintGroupStore()) {
            onUnlock()
        } else {
            showError = true
            pin = ""
        }
    }
}
