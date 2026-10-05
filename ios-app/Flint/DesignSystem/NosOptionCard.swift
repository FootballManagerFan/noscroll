import SwiftUI

/// Selectable answer / choice card. Selected = baby-blue fill + 2pt accent border.
struct NosOptionCard: View {
    var emoji: String?
    let title: String
    var subtitle: String?
    let isSelected: Bool
    var isMultiSelect: Bool = false
    var badge: String?
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: NosTheme.Radius.option, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let emoji {
                    Text(emoji).font(.system(size: 24))
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.nosHeadline)
                            .foregroundStyle(NosTheme.Colors.textPrimary)
                        if let badge {
                            NosBadge(badge)
                        }
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.nosCaption)
                            .foregroundStyle(NosTheme.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 8)
                indicator
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(shape.fill(isSelected ? NosTheme.Colors.selectedFill : NosTheme.Colors.surface))
            .overlay(
                shape.strokeBorder(
                    isSelected ? NosTheme.Colors.accent : NosTheme.Colors.border,
                    lineWidth: isSelected ? 2 : 1
                )
            )
            .contentShape(shape)
        }
        .buttonStyle(NosPressableStyle())
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var indicator: some View {
        if isMultiSelect {
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? NosTheme.Colors.accent : NosTheme.Colors.border)
        } else if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(NosTheme.Colors.accent)
        }
    }
}

#Preview("Option cards") {
    VStack(spacing: 12) {
        NosOptionCard(emoji: "📱", title: "4–6 hours", isSelected: true) {}
        NosOptionCard(emoji: "🎬", title: "Short video", isSelected: false, isMultiSelect: true) {}
        NosOptionCard(emoji: "🎬", title: "Short video", isSelected: true, isMultiSelect: true) {}
        NosOptionCard(
            emoji: "🔒",
            title: "Hardcore",
            subtitle: "Can't be stopped until it ends.",
            isSelected: false,
            badge: "Pro"
        ) {}
    }
    .padding(20)
    .background(NosTheme.Colors.background)
}
