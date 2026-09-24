import Testing
@testable import FluidSwiftUI

struct SwiftUINodeTests {

    @Test func sameLeafCasesWithEqualValuesAreEqual() {
        #expect(SwiftUINode.text("Hello") == SwiftUINode.text("Hello"))
        #expect(SwiftUINode.image(url: "https://example.com") == SwiftUINode.image(url: "https://example.com"))
    }

    @Test func leafCasesWithDifferentValuesAreNotEqual() {
        #expect(SwiftUINode.text("Hello") != SwiftUINode.text("World"))
        #expect(SwiftUINode.text("Hello") != SwiftUINode.image(url: "Hello"))
    }

    @Test func buttonComparesTitleAndURL() {
        let a = SwiftUINode.button(title: "Go", url: "https://example.com")
        let b = SwiftUINode.button(title: "Go", url: "https://example.com")
        let c = SwiftUINode.button(title: "Go", url: "https://other.com")
        #expect(a == b)
        #expect(a != c)
    }

    @Test func vstackComparesAlignmentSpacingAndChildren() {
        let a = SwiftUINode.vstack(alignment: .leading, spacing: 8, children: [.text("A")])
        let b = SwiftUINode.vstack(alignment: .leading, spacing: 8, children: [.text("A")])
        let differentAlignment = SwiftUINode.vstack(alignment: .center, spacing: 8, children: [.text("A")])
        let differentSpacing = SwiftUINode.vstack(alignment: .leading, spacing: nil, children: [.text("A")])
        let differentChildren = SwiftUINode.vstack(alignment: .leading, spacing: 8, children: [.text("B")])
        #expect(a == b)
        #expect(a != differentAlignment)
        #expect(a != differentSpacing)
        #expect(a != differentChildren)
    }

    @Test func hstackComparesAlignmentSpacingAndChildren() {
        let a = SwiftUINode.hstack(alignment: .top, spacing: nil, children: [])
        let b = SwiftUINode.hstack(alignment: .top, spacing: nil, children: [])
        let differentAlignment = SwiftUINode.hstack(alignment: .bottom, spacing: nil, children: [])
        #expect(a == b)
        #expect(a != differentAlignment)
    }

    @Test func zstackComparesAlignmentAndChildren() {
        let a = SwiftUINode.zstack(alignment: .topLeading, children: [.text("A")])
        let b = SwiftUINode.zstack(alignment: .topLeading, children: [.text("A")])
        let different = SwiftUINode.zstack(alignment: .bottomTrailing, children: [.text("A")])
        #expect(a == b)
        #expect(a != different)
    }

    @Test func indirectModifierNodesNestChildRecursively() {
        let inner = SwiftUINode.text("Hi")
        let padded = SwiftUINode.padding(amount: 8, child: inner)
        let backgrounded = SwiftUINode.background(hex: "#FFFFFF", child: padded)
        let sized = SwiftUINode.fontSize(size: 16, child: backgrounded)
        let rounded = SwiftUINode.cornerRadius(radius: 4, child: sized)
        let tinted = SwiftUINode.tint(hex: "#000000", child: rounded)
        let styled = SwiftUINode.foregroundStyle(hex: "#123456", child: tinted)
        let framed = SwiftUINode.frame(width: 100, height: nil, child: styled)
        let clipped = SwiftUINode.clipShape(shape: .circle, child: framed)

        // Rebuilding the same structure independently should compare equal.
        let rebuilt = SwiftUINode.clipShape(
            shape: .circle,
            child: .frame(
                width: 100, height: nil,
                child: .foregroundStyle(
                    hex: "#123456",
                    child: .tint(
                        hex: "#000000",
                        child: .cornerRadius(
                            radius: 4,
                            child: .fontSize(
                                size: 16,
                                child: .background(hex: "#FFFFFF", child: .padding(amount: 8, child: .text("Hi")))
                            )
                        )
                    )
                )
            )
        )
        #expect(clipped == rebuilt)
    }

    @Test func modifierNodesWithDifferentChildrenAreNotEqual() {
        let a = SwiftUINode.padding(amount: 8, child: .text("A"))
        let b = SwiftUINode.padding(amount: 8, child: .text("B"))
        #expect(a != b)
    }

    @Test func frameAllowsNilWidthOrHeightIndependently() {
        let widthOnly = SwiftUINode.frame(width: 100, height: nil, child: .text("A"))
        let heightOnly = SwiftUINode.frame(width: nil, height: 100, child: .text("A"))
        #expect(widthOnly != heightOnly)
    }

    @Test func alignmentValueEnumsAreEquatable() {
        #expect(HorizontalAlignmentValue.leading == .leading)
        #expect(HorizontalAlignmentValue.leading != .trailing)
        #expect(VerticalAlignmentValue.top == .top)
        #expect(VerticalAlignmentValue.top != .bottom)
        #expect(AlignmentValue.topLeading == .topLeading)
        #expect(AlignmentValue.topLeading != .bottomTrailing)
        #expect(ClipShapeValue.circle == .circle)
    }
}
