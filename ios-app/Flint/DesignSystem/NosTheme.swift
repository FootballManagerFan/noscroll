import SwiftUI
import UIKit
import FlintCore

/// noScroll's light-only design tokens, bound from `FlintBrand` (which mirrors design/tokens.json).
enum NosTheme {
    enum Colors {
        static let background = FlintBrand.stone
        static let surface = Color.white
        static let border = FlintBrand.cardBorder
        static let textPrimary = FlintBrand.flint
        static let textSecondary = FlintBrand.graphite
        static let accent = FlintBrand.spark
        static let accentPressed = FlintBrand.bronze
        static let accentSoft = FlintBrand.ember
        static let selectedFill = FlintBrand.selectedFill
        static let ink = FlintBrand.flint
        static let danger = Color(red: 0.753, green: 0.224, blue: 0.169)
        static let success = Color(red: 0.133, green: 0.6, blue: 0.369)
    }

    static let accentGradient = LinearGradient(
        colors: [FlintBrand.gradientStart, FlintBrand.gradientEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let gutter: CGFloat = 20
    }

    enum Radius {
        static let tile: CGFloat = 14
        static let option: CGFloat = 18
        static let card: CGFloat = 20
    }

    /// Global UIKit chrome (tab bar, navigation bar) so stock containers match the cards.
    static func applyChromeAppearance() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = .white
        tab.shadowColor = UIColor(FlintBrand.cardBorder)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().unselectedItemTintColor = UIColor(FlintBrand.graphite)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(FlintBrand.stone)
        nav.shadowColor = .clear
        let ink = UIColor(FlintBrand.flint)
        nav.titleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        ]
        nav.largeTitleTextAttributes = [
            .foregroundColor: ink,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }
}

extension Font {
    static let nosLargeTitle = Font.system(size: 30, weight: .bold)
    static let nosTitle = Font.system(size: 22, weight: .bold)
    static let nosHeadline = Font.system(size: 17, weight: .semibold)
    static let nosBody = Font.system(size: 17)
    static let nosSubheadline = Font.system(size: 15)
    static let nosCaption = Font.system(size: 13)
    static let nosLabel = Font.system(size: 12, weight: .semibold)

    static func nosNumber(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

extension Text {
    /// Screen headline: heavy, tight, ink.
    func nosLargeTitle() -> some View {
        font(.nosLargeTitle)
            .tracking(-0.5)
            .foregroundStyle(NosTheme.Colors.textPrimary)
    }

    /// Supporting line under a headline.
    func nosSubtitle() -> some View {
        font(.nosSubheadline)
            .foregroundStyle(NosTheme.Colors.textSecondary)
    }

    /// Small uppercase eyebrow above a group.
    func nosEyebrow() -> some View {
        font(.nosLabel)
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(NosTheme.Colors.textSecondary)
    }
}

extension View {
    /// Light-canvas styling for the remaining stock `Form`s: cloud background, white rows.
    func nosFormStyle() -> some View {
        scrollContentBackground(.hidden)
            .background(NosTheme.Colors.background.ignoresSafeArea())
            .tint(NosTheme.Colors.accent)
    }
}

enum NosHaptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
