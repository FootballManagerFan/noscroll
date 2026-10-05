import SwiftUI

/// Round back button + capsule progress bar for step-by-step flows.
struct NosProgressHeader: View {
    let progress: Double
    var onBack: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(NosTheme.Colors.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(NosTheme.Colors.surface))
                        .overlay(Circle().strokeBorder(NosTheme.Colors.border, lineWidth: 1))
                }
                .buttonStyle(NosPressableStyle())
                .accessibilityLabel("Back")
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(NosTheme.Colors.accentSoft.opacity(0.45))
                    Capsule()
                        .fill(NosTheme.Colors.accent)
                        .frame(width: max(8, geo.size.width * min(max(progress, 0), 1)))
                }
            }
            .frame(height: 6)
            .animation(.easeInOut(duration: 0.3), value: progress)
            .accessibilityElement()
            .accessibilityLabel("Progress")
            .accessibilityValue("\(Int((min(max(progress, 0), 1) * 100).rounded())) percent")
        }
    }
}

#Preview("Progress header") {
    VStack(spacing: 24) {
        NosProgressHeader(progress: 0.2, onBack: {})
        NosProgressHeader(progress: 0.85, onBack: {})
        NosProgressHeader(progress: 0.1)
    }
    .padding(20)
    .background(NosTheme.Colors.background)
}
