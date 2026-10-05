import SwiftUI

/// The noScroll mark (design/logo-mark.svg): three feed lines cut by a hard slash.
struct NosMark: View {
    var size: CGFloat = 56
    var barColor: Color = NosTheme.Colors.ink
    var slashColor: Color = NosTheme.Colors.accent

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width / 56
            for y in [12.0, 24.5, 37.0] {
                let bar = CGRect(x: 7 * s, y: y * s, width: 42 * s, height: 7 * s)
                context.fill(Path(roundedRect: bar, cornerRadius: 3.5 * s), with: .color(barColor))
            }
            var slash = Path()
            slash.move(to: CGPoint(x: 4.5 * s, y: 51.5 * s))
            slash.addLine(to: CGPoint(x: 51.5 * s, y: 4.5 * s))
            context.stroke(slash, with: .color(slashColor), style: StrokeStyle(lineWidth: 8 * s, lineCap: .round))
        }
        .frame(width: size, height: size)
        .accessibilityLabel("noScroll")
    }
}

/// The app-icon treatment (design/app-icon.svg): ink tile, white lines, baby-blue slash.
struct NosAppIcon: View {
    var size: CGFloat = 88

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
            .fill(NosTheme.Colors.ink)
            .frame(width: size, height: size)
            .overlay(NosMark(size: size * 0.62, barColor: .white, slashColor: NosTheme.Colors.accentSoft))
            .shadow(color: NosTheme.Colors.ink.opacity(0.18), radius: 16, x: 0, y: 8)
            .accessibilityLabel("noScroll")
    }
}

#Preview("Mark") {
    HStack(spacing: 24) {
        NosMark()
        NosAppIcon()
    }
    .padding(40)
    .background(NosTheme.Colors.background)
}
