import SwiftUI

// MARK: - Icon tile

/// Rounded-square tile holding an emoji or SF Symbol — the leading visual on benefit and stat rows.
struct NosIconTile: View {
    enum Glyph {
        case emoji(String)
        case symbol(String)
    }

    let glyph: Glyph
    var size: CGFloat = 56
    var tint: Color = NosTheme.Colors.accent
    var fill: Color = NosTheme.Colors.surface

    init(emoji: String, size: CGFloat = 56, fill: Color = NosTheme.Colors.surface) {
        self.glyph = .emoji(emoji)
        self.size = size
        self.fill = fill
    }

    init(
        symbol: String,
        size: CGFloat = 56,
        tint: Color = NosTheme.Colors.accent,
        fill: Color = NosTheme.Colors.surface
    ) {
        self.glyph = .symbol(symbol)
        self.size = size
        self.tint = tint
        self.fill = fill
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
        ZStack {
            shape.fill(fill)
            shape.strokeBorder(NosTheme.Colors.border, lineWidth: 1)
            switch glyph {
            case .emoji(let emoji):
                Text(emoji).font(.system(size: size * 0.48))
            case .symbol(let name):
                Image(systemName: name)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Badge

struct NosBadge: View {
    enum Style { case filled, soft }

    let text: String
    var style: Style = .filled

    init(_ text: String, style: Style = .filled) {
        self.text = text
        self.style = style
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(style == .filled ? Color.white : NosTheme.Colors.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(style == .filled ? NosTheme.Colors.accent : NosTheme.Colors.selectedFill)
            )
    }
}

// MARK: - Stat card

/// Tile + big accent number + label, e.g. "~420 hrs · back this year".
struct NosStatCard: View {
    let tile: NosIconTile
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 14) {
            tile
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.nosNumber(30))
                    .monospacedDigit()
                    .foregroundStyle(NosTheme.Colors.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.nosSubheadline)
                    .foregroundStyle(NosTheme.Colors.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .nosCard()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Benefit row

/// Tile + one line of copy — the paywall / welcome feature list.
struct NosBenefitRow: View {
    let tile: NosIconTile
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            tile
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(NosTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Tiles") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            NosIconTile(emoji: "🛌")
            NosIconTile(symbol: "lock.fill")
            NosIconTile(symbol: "bolt.fill", fill: NosTheme.Colors.selectedFill)
            NosBadge("Pro")
            NosBadge("Best value", style: .soft)
        }
        NosStatCard(
            tile: NosIconTile(emoji: "⏳", fill: NosTheme.Colors.selectedFill),
            value: "~420 hrs",
            label: "back this year"
        )
        NosBenefitRow(tile: NosIconTile(symbol: "lock.shield.fill"), text: "Hardcore blocks you can't cancel")
    }
    .padding(20)
    .background(NosTheme.Colors.background)
}
