import SwiftUI

// MARK: - Card

struct NosCardModifier: ViewModifier {
    var padding: CGFloat
    var alignment: Alignment

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: alignment)
            .background(
                RoundedRectangle(cornerRadius: NosTheme.Radius.card, style: .continuous)
                    .fill(NosTheme.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: NosTheme.Radius.card, style: .continuous)
                    .strokeBorder(NosTheme.Colors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

extension View {
    /// White rounded card with a hairline border on the cloud canvas.
    func nosCard(padding: CGFloat = 16, alignment: Alignment = .leading) -> some View {
        modifier(NosCardModifier(padding: padding, alignment: alignment))
    }
}

// MARK: - Screen scaffold

/// Cloud-background scrolling page with the standard gutter.
struct NosScreen<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: Content

    init(
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: alignment, spacing: spacing) {
                content
            }
            .padding(.horizontal, NosTheme.Spacing.gutter)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .top))
        }
        .scrollDismissesKeyboard(.interactively)
        .background(NosTheme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - Sticky bottom bar

/// Pins content to the bottom safe area — the home of a screen's primary CTA.
struct NosStickyBar<Bar: View>: ViewModifier {
    var background: Color
    var showsDivider: Bool
    let bar: Bar

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 10) {
                bar
            }
            .padding(.horizontal, NosTheme.Spacing.gutter)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background(background.ignoresSafeArea(edges: .bottom))
            .overlay(alignment: .top) {
                if showsDivider {
                    Rectangle().fill(NosTheme.Colors.border).frame(height: 1)
                }
            }
        }
    }
}

extension View {
    func nosStickyBar<Bar: View>(
        background: Color = NosTheme.Colors.background,
        showsDivider: Bool = false,
        @ViewBuilder _ bar: () -> Bar
    ) -> some View {
        modifier(NosStickyBar(background: background, showsDivider: showsDivider, bar: bar()))
    }

    /// The common case: optional check-mark caption, one gradient button, optional fine print.
    func nosStickyCTA(
        _ title: String,
        caption: String? = nil,
        finePrint: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        nosStickyBar {
            if let caption {
                Label(caption, systemImage: "checkmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(NosTheme.Colors.textPrimary)
            }
            Button(title, action: action)
                .buttonStyle(.nosPrimary)
                .disabled(!isEnabled)
            if let finePrint {
                Text(finePrint)
                    .font(.nosCaption)
                    .foregroundStyle(NosTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview("Screen + card + sticky CTA") {
    NosScreen {
        Text("Ready to focus").nosLargeTitle()
        Text("Pick what to block and for how long.").nosSubtitle()
        VStack(alignment: .leading, spacing: 6) {
            Text("Today").nosEyebrow()
            Text("2h 14m").font(.nosNumber(34)).foregroundStyle(NosTheme.Colors.accent)
        }
        .nosCard()
    }
    .nosStickyCTA("Start Focus", caption: "Nothing leaves your phone", finePrint: "Stop anytime on Easy.") {}
}
