import SwiftUI

/// Tile + title + message + one primary action, for screens with nothing in them yet.
struct NosEmptyState: View {
    let symbol: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            NosIconTile(symbol: symbol, size: 64, fill: NosTheme.Colors.selectedFill)
            Text(title)
                .font(.nosTitle)
                .foregroundStyle(NosTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.nosSubheadline)
                .foregroundStyle(NosTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button(actionTitle, action: action)
                .buttonStyle(.nosPrimary)
                .padding(.top, 6)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 8)
    }
}

#Preview("Empty state") {
    NosEmptyState(
        symbol: "calendar.badge.clock",
        title: "No schedules yet",
        message: "Recurring blocks — work hours, bedtime, study time.",
        actionTitle: "Add a schedule"
    ) {}
    .padding(20)
    .background(NosTheme.Colors.background)
}
