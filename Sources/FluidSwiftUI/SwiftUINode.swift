import Foundation

/// A node in the parsed representation of a small SwiftUI-like DSL.
enum SwiftUINode: Equatable {
    case text(String)
    case image(url: String)
    case vstack(alignment: HorizontalAlignmentValue, spacing: Double?, children: [SwiftUINode])
    case hstack(alignment: VerticalAlignmentValue, spacing: Double?, children: [SwiftUINode])
    case zstack(alignment: AlignmentValue, children: [SwiftUINode])
    case button(title: String, url: String)
    indirect case padding(amount: Double?, child: SwiftUINode)
    indirect case background(hex: String, child: SwiftUINode)
    indirect case fontSize(size: Double, child: SwiftUINode)
    indirect case cornerRadius(radius: Double, child: SwiftUINode)
    indirect case tint(hex: String, child: SwiftUINode)
    indirect case foregroundStyle(hex: String, child: SwiftUINode)
    indirect case frame(width: Double?, height: Double?, child: SwiftUINode)
    indirect case clipShape(shape: ClipShapeValue, child: SwiftUINode)
}

/// Mirrors the small subset of SwiftUI `Shape`s supported by the `.clipShape` modifier.
enum ClipShapeValue: Equatable {
    case circle
}

/// Mirrors `SwiftUI.HorizontalAlignment`'s common cases, used as `VStack`'s `alignment:` parameter.
enum HorizontalAlignmentValue: Equatable {
    case leading, center, trailing
}

/// Mirrors `SwiftUI.VerticalAlignment`'s common cases, used as `HStack`'s `alignment:` parameter.
enum VerticalAlignmentValue: Equatable {
    case top, center, bottom
}

/// Mirrors `SwiftUI.Alignment`'s common cases, used as `ZStack`'s `alignment:` parameter.
enum AlignmentValue: Equatable {
    case topLeading, top, topTrailing
    case leading, center, trailing
    case bottomLeading, bottom, bottomTrailing
}
