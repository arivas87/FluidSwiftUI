import SwiftUI
import FluidSwiftUI

struct StatusDashboardExample: View {
    private let code = #"""
    VStack(alignment: .leading, spacing: 16) {
        Text("**System status**")
            .fontSize(26)
            .foregroundStyle(Color(hex: "#F8FAFC"))

        HStack(alignment: .center, spacing: 12) {
            Text("API")
                .fontSize(17)
                .foregroundStyle(Color(hex: "#E2E8F0"))

            Text("Operational")
                .padding(8)
                .background(Color(hex: "#166534"))
                .cornerRadius(8)
                .foregroundStyle(Color(hex: "#DCFCE7"))
        }

        HStack(alignment: .center, spacing: 12) {
            Text("Renderer")
                .fontSize(17)
                .foregroundStyle(Color(hex: "#E2E8F0"))

            Text("Operational")
                .padding(8)
                .background(Color(hex: "#166534"))
                .cornerRadius(8)
                .foregroundStyle(Color(hex: "#DCFCE7"))
        }

        HStack(alignment: .center, spacing: 12) {
            Text("Image service")
                .fontSize(17)
                .foregroundStyle(Color(hex: "#E2E8F0"))

            Text("Maintenance")
                .padding(8)
                .background(Color(hex: "#92400E"))
                .cornerRadius(8)
                .foregroundStyle(Color(hex: "#FEF3C7"))
        }

        Button("View incident history", url: "https://example.com/status")
            .tint(Color(hex: "#7DD3FC"))
    }
    .padding(22)
    .background(Color(hex: "#1E293B"))
    .cornerRadius(18)
    """#

    var body: some View {
        FluidSwiftUIView(code: code)
    }
}

#Preview {
    StatusDashboardExample()
        .padding()
}
