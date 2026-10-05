import SwiftUI

/// Full-width gradient pill — the one primary action on a screen.
struct NosPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(NosTheme.accentGradient, in: Capsule())
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { NosHaptics.tap() }
            }
    }
}

/// White bordered pill for secondary actions; pass a tint for destructive ones.
struct NosSecondaryButtonStyle: ButtonStyle {
    var tint: Color = NosTheme.Colors.textPrimary
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(tint)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Capsule().fill(Color.white))
            .overlay(Capsule().strokeBorder(NosTheme.Colors.border, lineWidth: 1))
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Plain accent-colored text action ("Restore Purchases", "Continue with free").
struct NosTextButtonStyle: ButtonStyle {
    var tint: Color = NosTheme.Colors.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(tint)
            .frame(minHeight: 44)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

/// No chrome, just a press-scale — for custom tappable cards.
struct NosPressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == NosPrimaryButtonStyle {
    static var nosPrimary: NosPrimaryButtonStyle { NosPrimaryButtonStyle() }
}

extension ButtonStyle where Self == NosSecondaryButtonStyle {
    static var nosSecondary: NosSecondaryButtonStyle { NosSecondaryButtonStyle() }
    static func nosSecondary(tint: Color) -> NosSecondaryButtonStyle { NosSecondaryButtonStyle(tint: tint) }
}

extension ButtonStyle where Self == NosTextButtonStyle {
    static var nosText: NosTextButtonStyle { NosTextButtonStyle() }
}

#Preview("Buttons") {
    VStack(spacing: 16) {
        Button("Start Focus") {}.buttonStyle(.nosPrimary)
        Button("Start Focus") {}.buttonStyle(.nosPrimary).disabled(true)
        Button("Choose apps") {}.buttonStyle(.nosSecondary)
        Button("Stop") {}.buttonStyle(.nosSecondary(tint: NosTheme.Colors.danger))
        Button("Restore Purchases") {}.buttonStyle(.nosText)
    }
    .padding(20)
    .background(NosTheme.Colors.background)
}
