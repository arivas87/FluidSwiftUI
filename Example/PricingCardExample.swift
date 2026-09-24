import SwiftUI
import FluidSwiftUI

struct PricingCardExample: View {
    private let code = #"""
    VStack(alignment: .leading, spacing: 14) {
        Text("**Pro plan**")
            .fontSize(24)
            .foregroundStyle(Color(hex: "#312E81"))

        HStack(alignment: .bottom, spacing: 6) {
            Text("€12")
                .fontSize(38)
                .foregroundStyle(Color(hex: "#111827"))

            Text("per month")
                .fontSize(15)
                .foregroundStyle(Color(hex: "#6B7280"))
        }

        Text("✓ Unlimited rendered views")
        Text("✓ Remote images and Markdown")
        Text("✓ Buttons with URL actions")

        Button("Start free trial", url: "https://example.com/signup")
            .padding(14)
            .background(Color(hex: "#4F46E5"))
            .cornerRadius(10)
            .tint(Color(hex: "#FFFFFF"))
    }
    .padding(24)
    .background(Color(hex: "#EEF2FF"))
    .cornerRadius(18)
    """#

    var body: some View {
        FluidSwiftUIView(code: code)
    }
}

#Preview {
    PricingCardExample()
        .padding()
}
