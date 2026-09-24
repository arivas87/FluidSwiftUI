import SwiftUI
import FluidSwiftUI

struct WelcomeCardExample: View {
    private let code = #"""
    VStack(alignment: .leading, spacing: 12) {
        Text("**Welcome to FluidSwiftUI**")
            .fontSize(30)
            .foregroundStyle(Color(hex: "#F8FAFC"))

        Text("Build native views from a small, controlled SwiftUI-like language.")
            .fontSize(17)
            .foregroundStyle(Color(hex: "#CBD5E1"))

        Button("Read the documentation", url: "https://github.com/arivas87/FluidSwiftUI")
            .padding(12)
            .background(Color(hex: "#38BDF8"))
            .cornerRadius(10)
            .tint(Color(hex: "#082F49"))
    }
    .padding(24)
    .background(Color(hex: "#0F172A"))
    .cornerRadius(18)
    """#

    var body: some View {
        FluidSwiftUIView(code: code)
    }
}

#Preview {
    WelcomeCardExample()
        .padding()
}
