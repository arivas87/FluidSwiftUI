import SwiftUI
import FluidSwiftUI

struct ArticleHeroExample: View {
    private let code = #"""
    ZStack(alignment: .bottomLeading) {
        Image(url: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee")
            .frame(width: 340, height: 240)

        VStack(alignment: .leading, spacing: 6) {
            Text("TRAVEL")
                .fontSize(13)
                .foregroundStyle(Color(hex: "#FDE68A"))

            Text("**A quiet weekend in the mountains**")
                .fontSize(26)
                .foregroundStyle(Color(hex: "#FFFFFF"))

            Text("Six trails, one cabin, and no notifications.")
                .fontSize(15)
                .foregroundStyle(Color(hex: "#E5E7EB"))
        }
        .padding(18)
        .background(Color(hex: "#111827CC"))
        .cornerRadius(12)
    }
    .cornerRadius(20)
    """#

    var body: some View {
        FluidSwiftUIView(code: code)
    }
}

#Preview {
    ArticleHeroExample()
        .padding()
}
