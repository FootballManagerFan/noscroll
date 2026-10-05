import SwiftUI
import FamilyControls
import FlintCore

/// Focus tab — Block Now: pick apps → duration → strictness → start; live countdown while active.
struct ContentView: View {
    @StateObject private var auth = AuthorizationModel()
    @StateObject private var vm = SessionViewModel()
    @EnvironmentObject private var entitlements: Entitlements
    @State private var showPaywall = false
    @State private var showPicker = false
    @State private var showSaveGroup = false
    @State private var showPriming = false
    @State private var confirmStop = false
    @State private var groupName = ""

    private let durationPresets = [15, 25, 45, 60, 90]

    var body: some View {
        NavigationStack {
            screen
                .toolbar(.hidden, for: .navigationBar)
                .familyActivityPicker(isPresented: $showPicker, selection: $vm.selection)
                .onChange(of: vm.selection) { _ in vm.persistSelection() }
                .onChange(of: entitlements.isPro) { isPro in
                    if !isPro && vm.breakLevel == .hardcore { vm.breakLevel = .easy }
                }
                .alert("Save as group", isPresented: $showSaveGroup) {
                    TextField("Name", text: $groupName)
                    Button("Save") { vm.saveSelectionAsGroup(name: groupName); groupName = "" }
                    Button("Cancel", role: .cancel) { groupName = "" }
                }
                .confirmationDialog(
                    "Stop this session early?",
                    isPresented: $confirmStop,
                    titleVisibility: .visible
                ) {
                    Button("Stop session", role: .destructive) { vm.stop() }
                    Button("Keep focusing", role: .cancel) {}
                } message: {
                    Text("You picked Harder for a reason.")
                }
                .sheet(isPresented: $showPriming, onDismiss: { auth.refresh() }) {
                    ScreenTimePrimingView(
                        auth: auth,
                        onBack: { showPriming = false },
                        onFinish: { showPriming = false }
                    )
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView { showPaywall = false }
                }
                .task { auth.refresh() }
        }
    }

    private var isSettingUp: Bool { auth.status == .approved && vm.active == nil }

    @ViewBuilder private var screen: some View {
        let page = NosScreen(spacing: 24) {
            header
            switch auth.status {
            case .approved:
                if let active = vm.active {
                    activeCard(active)
                } else {
                    blockTargetSection
                    durationSection
                    strictnessSection
                }
            default:
                accessCard
            }
            if let message = vm.errorText ?? auth.lastError {
                errorBanner(message)
            }
        }
        if isSettingUp {
            page.nosStickyCTA(
                "Start Focus",
                finePrint: vm.selectionCount == 0 ? "Choose at least one app or site first." : nil,
                isEnabled: vm.selectionCount > 0
            ) {
                vm.start()
            }
        } else {
            page
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting).nosEyebrow()
                Text(vm.active == nil ? "Ready to focus?" : "Phone down.")
                    .nosLargeTitle()
            }
            Spacer()
            NosMark(size: 36)
        }
        .padding(.top, 8)
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    // MARK: Setup

    private var blockTargetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What to block").nosEyebrow()
            Button { showPicker = true } label: {
                HStack(spacing: 14) {
                    NosIconTile(symbol: "square.grid.2x2.fill", size: 48, fill: NosTheme.Colors.selectedFill)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.selectionCount == 0 ? "Choose apps & sites" : "\(vm.selectionCount) apps & sites")
                            .font(.nosHeadline)
                            .foregroundStyle(NosTheme.Colors.textPrimary)
                        Text(vm.selectionCount == 0 ? "Pick what pulls you in" : "Tap to change")
                            .font(.nosCaption)
                            .foregroundStyle(NosTheme.Colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(NosTheme.Colors.textSecondary)
                }
                .nosCard()
            }
            .buttonStyle(NosPressableStyle())

            if !vm.savedGroups.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.savedGroups) { group in
                            Button { vm.applyGroup(group) } label: {
                                chip("\(group.name) · \(group.itemCount)", isSelected: false)
                            }
                            .buttonStyle(NosPressableStyle())
                        }
                    }
                }
            }
            if vm.selectionCount > 0 {
                Button("Save selection as group") { showSaveGroup = true }
                    .buttonStyle(.nosText)
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How long").nosEyebrow()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(durationPresets, id: \.self) { minutes in
                        Button { vm.durationMinutes = minutes } label: {
                            chip("\(minutes) min", isSelected: vm.durationMinutes == minutes)
                        }
                        .buttonStyle(NosPressableStyle())
                    }
                }
            }
            HStack {
                Text("Custom")
                    .font(.nosHeadline)
                    .foregroundStyle(NosTheme.Colors.textPrimary)
                Spacer()
                Text("\(vm.durationMinutes) min")
                    .font(.nosHeadline)
                    .monospacedDigit()
                    .foregroundStyle(NosTheme.Colors.accent)
                Stepper("Duration", value: $vm.durationMinutes, in: 5...240, step: 5)
                    .labelsHidden()
            }
            .nosCard(padding: 14)
        }
    }

    private var strictnessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Strictness").nosEyebrow()
            NosOptionCard(
                emoji: "🌱",
                title: "Easy",
                subtitle: "Stop anytime.",
                isSelected: vm.breakLevel == .easy
            ) { vm.breakLevel = .easy }
            NosOptionCard(
                emoji: "🧱",
                title: "Harder",
                subtitle: "Stopping early asks you to confirm.",
                isSelected: vm.breakLevel == .harder
            ) { vm.breakLevel = .harder }
            NosOptionCard(
                emoji: "🔒",
                title: "Hardcore",
                subtitle: "Can't be stopped until it ends, and noScroll can't be deleted while it runs.",
                isSelected: vm.breakLevel == .hardcore,
                badge: entitlements.isPro ? nil : "Pro"
            ) {
                if entitlements.isPro { vm.breakLevel = .hardcore } else { showPaywall = true }
            }
        }
    }

    private func chip(_ text: String, isSelected: Bool) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(isSelected ? Color.white : NosTheme.Colors.textPrimary)
            .padding(.horizontal, 16)
            .frame(minHeight: 40)
            .background(Capsule().fill(isSelected ? NosTheme.Colors.accent : NosTheme.Colors.surface))
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : NosTheme.Colors.border, lineWidth: 1))
    }

    // MARK: Access

    private var accessCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                NosIconTile(symbol: "hourglass", size: 48, fill: NosTheme.Colors.selectedFill)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Screen Time access needed")
                        .font(.nosHeadline)
                        .foregroundStyle(NosTheme.Colors.textPrimary)
                    Text("noScroll can't shield apps until iOS allows it. Nothing leaves your phone.")
                        .font(.nosCaption)
                        .foregroundStyle(NosTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button("Turn on Screen Time access") { showPriming = true }
                .buttonStyle(.nosPrimary)
        }
        .nosCard(padding: 20)
    }

    // MARK: Active session

    private func activeCard(_ active: FlintActiveSession) -> some View {
        VStack(spacing: 18) {
            NosBadge("Focus active")

            ZStack {
                Circle()
                    .stroke(NosTheme.Colors.accentSoft.opacity(0.35), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: elapsedFraction(active))
                    .stroke(NosTheme.accentGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: vm.remaining)
                VStack(spacing: 4) {
                    if active.endsAt != nil {
                        Text(timeString(vm.remaining))
                            .font(.nosNumber(52))
                            .monospacedDigit()
                            .foregroundStyle(NosTheme.Colors.textPrimary)
                    } else {
                        Text("No limit")
                            .font(.nosTitle)
                            .foregroundStyle(NosTheme.Colors.textPrimary)
                    }
                    Text(levelLabel(active.breakLevel))
                        .font(.nosCaption.weight(.semibold))
                        .foregroundStyle(NosTheme.Colors.accent)
                }
            }
            .frame(width: 230, height: 230)
            .padding(.vertical, 4)

            if let endsAt = active.endsAt {
                Text("Ends at \(endsAt.formatted(date: .omitted, time: .shortened))")
                    .font(.nosSubheadline)
                    .foregroundStyle(NosTheme.Colors.textSecondary)
            }

            if vm.canStopActive {
                Button("Stop session") {
                    if active.breakLevel == .harder { confirmStop = true } else { vm.stop() }
                }
                .buttonStyle(.nosSecondary(tint: NosTheme.Colors.danger))
            } else {
                lockedSection(active)
            }
        }
        .nosCard(padding: 24, alignment: .center)
    }

    private func lockedSection(_ active: FlintActiveSession) -> some View {
        VStack(spacing: 12) {
            Label("Locked until it ends", systemImage: "lock.fill")
                .font(.nosHeadline)
                .foregroundStyle(NosTheme.Colors.textPrimary)
            if active.breakLevel == .hardcore {
                Text("noScroll can't be deleted while Hardcore is active.")
                    .font(.nosCaption)
                    .foregroundStyle(NosTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if !entitlements.isPro {
                Button { showPaywall = true } label: {
                    HStack(spacing: 8) {
                        Label("Emergency Pass", systemImage: "key.fill")
                        NosBadge("Pro")
                    }
                }
                .buttonStyle(.nosSecondary)
            } else if vm.emergencyPassAvailable {
                Button { vm.useEmergencyPass() } label: {
                    Label("Use Emergency Pass (1 a week)", systemImage: "key.fill")
                }
                .buttonStyle(.nosSecondary)
            } else {
                Text("Emergency Pass already used this week.")
                    .font(.nosCaption)
                    .foregroundStyle(NosTheme.Colors.textSecondary)
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.nosCaption)
            .foregroundStyle(NosTheme.Colors.danger)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: NosTheme.Radius.option, style: .continuous)
                    .fill(NosTheme.Colors.danger.opacity(0.08))
            )
    }

    // MARK: Helpers

    private func elapsedFraction(_ active: FlintActiveSession) -> CGFloat {
        guard let endsAt = active.endsAt else { return 1 }
        let total = endsAt.timeIntervalSince(active.startedAt)
        guard total > 0 else { return 1 }
        return CGFloat(min(max(1 - vm.remaining / total, 0), 1))
    }

    private func levelLabel(_ level: BreakLevel) -> String {
        switch level {
        case .easy: "Easy"
        case .harder: "Harder"
        case .hardcore: "Hardcore"
        }
    }

    private func timeString(_ t: TimeInterval) -> String {
        let total = Int(t.rounded())
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
    }
}
