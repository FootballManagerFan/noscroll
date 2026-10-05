import SwiftUI
import FlintCore

struct TotalActivityView: View {
    let totalActivity: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Screen time today")
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(FlintBrand.graphite)
            Text(totalActivity)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(FlintBrand.spark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
    }
}

#Preview {
    TotalActivityView(totalActivity: "2h 14m")
}
