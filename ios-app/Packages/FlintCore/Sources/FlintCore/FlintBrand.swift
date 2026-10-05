import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// noScroll brand palette. Mirror of design/tokens.json — keep in sync.
/// Provides both SwiftUI `Color` (host app) and `UIColor` (shield extension) accessors.
///
/// Symbol names below still say `Flint*`/`flint*` — a code-identifier rename (this type, the
/// `com.flint.peakfocus`-equivalent bundle IDs, the App Group, and every call site) is a
/// separate, larger follow-up; only the hex values have been repointed to the noScroll palette.
public enum FlintBrand {
    public static let flintHex: UInt32 = 0x0B1120 // Ink
    public static let graphiteHex: UInt32 = 0x55606B // Slate
    public static let sparkHex: UInt32 = 0x1F6BFF // Pop Blue — primary accent
    public static let emberHex: UInt32 = 0x9FD8F5 // Baby Blue — signature/light accent
    public static let bronzeHex: UInt32 = 0x1650D6 // Deep Blue — pressed state
    public static let stoneHex: UInt32 = 0xF2FAFF // Cloud
    public static let onAccentHex: UInt32 = 0xFFFFFF // text/icon on Pop Blue / Deep Blue
    public static let onAccentMutedHex: UInt32 = 0x0B1120 // text/icon on Baby Blue
    public static let mistHex: UInt32 = 0x9FB3C8 // secondary text on dark
    public static let selectedFillHex: UInt32 = 0xE3F3FC // selected option / plan card fill
    public static let cardBorderHex: UInt32 = 0xDCE9F3 // hairline around white cards
    public static let gradientStartHex: UInt32 = 0x4A8DFF // primary CTA gradient, leading
    public static let gradientEndHex: UInt32 = 0x1F5EFF // primary CTA gradient, trailing

    public static var flint: Color { color(flintHex) }
    public static var graphite: Color { color(graphiteHex) }
    public static var spark: Color { color(sparkHex) }
    public static var ember: Color { color(emberHex) }
    public static var bronze: Color { color(bronzeHex) }
    public static var stone: Color { color(stoneHex) }
    public static var onAccent: Color { color(onAccentHex) }
    public static var onAccentMuted: Color { color(onAccentMutedHex) }
    public static var mist: Color { color(mistHex) }
    public static var selectedFill: Color { color(selectedFillHex) }
    public static var cardBorder: Color { color(cardBorderHex) }
    public static var gradientStart: Color { color(gradientStartHex) }
    public static var gradientEnd: Color { color(gradientEndHex) }

    private static func color(_ hex: UInt32) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }

    #if canImport(UIKit)
    public static var flintUI: UIColor { uiColor(flintHex) }
    public static var sparkUI: UIColor { uiColor(sparkHex) }
    public static var stoneUI: UIColor { uiColor(stoneHex) }
    public static var onAccentUI: UIColor { uiColor(onAccentHex) }

    private static func uiColor(_ hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    #endif
}
