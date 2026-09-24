import SwiftUI
import FluidSwiftUI

struct ProfileCardExample: View {
    private let code = #"""
    HStack(alignment: .top, spacing: 16) {
        Image(url: "https://images.unsplash.com/photo-1494790108377-be9c29b29330")
            .frame(width: 88, height: 88)
            .clipShape(.circle)

        VStack(alignment: .leading, spacing: 8) {
            Text("**Maya Chen**")
                .fontSize(22)
                .foregroundStyle(Color(hex: "#111827"))

            Text("*iOS developer* · Madrid")
                .fontSize(15)
                .foregroundStyle(Color(hex: "#6B7280"))

            Button("View portfolio", url: "https://example.com/portfolio")
                .padding(10)
                .background(Color(hex: "#4F46E5"))
                .cornerRadius(8)
                .tint(Color(hex: "#FFFFFF"))
        }
    }
    .padding(20)
    .background(Color(hex: "#F9FAFB"))
    .cornerRadius(16)
    """#

    var body: some View {
        FluidSwiftUIView(code: code)
    }
}

#Preview {
    ProfileCardExample()
        .padding()
}
