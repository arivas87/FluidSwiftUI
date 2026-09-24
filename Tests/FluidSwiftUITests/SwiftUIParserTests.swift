import Testing
@testable import FluidSwiftUI

struct SwiftUIParserTests {

    // MARK: - Leaf views

    @Test func parsesText() throws {
        let nodes = try SwiftUIParser.parse(#"Text("Hello")"#)
        #expect(nodes == [.text("Hello")])
    }

    @Test func parsesImage() throws {
        let nodes = try SwiftUIParser.parse(#"Image(url: "https://example.com/photo.png")"#)
        #expect(nodes == [.image(url: "https://example.com/photo.png")])
    }

    @Test func parsesButton() throws {
        let nodes = try SwiftUIParser.parse(#"Button("Open", url: "https://example.com")"#)
        #expect(nodes == [.button(title: "Open", url: "https://example.com")])
    }

    // MARK: - Stacks

    @Test func parsesVStackWithDefaults() throws {
        let nodes = try SwiftUIParser.parse(#"VStack { Text("A") }"#)
        #expect(nodes == [.vstack(alignment: .center, spacing: nil, children: [.text("A")])])
    }

    @Test func parsesVStackWithAlignmentAndSpacing() throws {
        let nodes = try SwiftUIParser.parse(#"VStack(alignment: .leading, spacing: 8) { Text("A") }"#)
        #expect(nodes == [.vstack(alignment: .leading, spacing: 8, children: [.text("A")])])
    }

    @Test func parsesVStackArgumentsInEitherOrder() throws {
        let nodes = try SwiftUIParser.parse(#"VStack(spacing: 8, alignment: .trailing) { Text("A") }"#)
        #expect(nodes == [.vstack(alignment: .trailing, spacing: 8, children: [.text("A")])])
    }

    @Test func parsesHStackWithAlignmentAndSpacing() throws {
        let nodes = try SwiftUIParser.parse(#"HStack(alignment: .bottom, spacing: 4) { Text("A") }"#)
        #expect(nodes == [.hstack(alignment: .bottom, spacing: 4, children: [.text("A")])])
    }

    @Test func parsesZStackWithAlignment() throws {
        let nodes = try SwiftUIParser.parse(#"ZStack(alignment: .topTrailing) { Text("A") }"#)
        #expect(nodes == [.zstack(alignment: .topTrailing, children: [.text("A")])])
    }

    @Test func parsesZStackWithDefaultAlignmentAndNoArguments() throws {
        let nodes = try SwiftUIParser.parse(#"ZStack { Text("A") }"#)
        #expect(nodes == [.zstack(alignment: .center, children: [.text("A")])])
    }

    @Test func parsesNestedChildren() throws {
        let nodes = try SwiftUIParser.parse(#"VStack { HStack { Text("A") } }"#)
        #expect(nodes == [.vstack(alignment: .center, spacing: nil, children: [
            .hstack(alignment: .center, spacing: nil, children: [.text("A")])
        ])])
    }

    @Test func parsesMultipleTopLevelStatements() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A") Text("B")"#)
        #expect(nodes == [.text("A"), .text("B")])
    }

    @Test func parsesMultipleChildrenInsideAStack() throws {
        let nodes = try SwiftUIParser.parse(#"VStack { Text("A") Text("B") }"#)
        #expect(nodes == [.vstack(alignment: .center, spacing: nil, children: [.text("A"), .text("B")])])
    }

    // MARK: - Modifiers

    @Test func parsesPaddingWithoutArgument() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").padding()"#)
        #expect(nodes == [.padding(amount: nil, child: .text("A"))])
    }

    @Test func parsesPaddingWithArgument() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").padding(8)"#)
        #expect(nodes == [.padding(amount: 8, child: .text("A"))])
    }

    @Test func parsesBackgroundModifier() throws {
        let nodes = try SwiftUIParser.parse(##"Text("A").background(Color(hex: "#FFFFFF"))"##)
        #expect(nodes == [.background(hex: "#FFFFFF", child: .text("A"))])
    }

    @Test func parsesFontSizeModifier() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").fontSize(16)"#)
        #expect(nodes == [.fontSize(size: 16, child: .text("A"))])
    }

    @Test func parsesCornerRadiusModifier() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").cornerRadius(4)"#)
        #expect(nodes == [.cornerRadius(radius: 4, child: .text("A"))])
    }

    @Test func parsesTintModifier() throws {
        let nodes = try SwiftUIParser.parse(##"Text("A").tint(Color(hex: "#000000"))"##)
        #expect(nodes == [.tint(hex: "#000000", child: .text("A"))])
    }

    @Test func parsesForegroundStyleModifier() throws {
        let nodes = try SwiftUIParser.parse(##"Text("A").foregroundStyle(Color(hex: "#123456"))"##)
        #expect(nodes == [.foregroundStyle(hex: "#123456", child: .text("A"))])
    }

    @Test func parsesFrameModifierWithBothArguments() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").frame(width: 100, height: 50)"#)
        #expect(nodes == [.frame(width: 100, height: 50, child: .text("A"))])
    }

    @Test func parsesFrameModifierWithWidthOnly() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").frame(width: 100)"#)
        #expect(nodes == [.frame(width: 100, height: nil, child: .text("A"))])
    }

    @Test func parsesFrameModifierArgumentsInEitherOrder() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").frame(height: 50, width: 100)"#)
        #expect(nodes == [.frame(width: 100, height: 50, child: .text("A"))])
    }

    @Test func parsesClipShapeCircle() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").clipShape(.circle)"#)
        #expect(nodes == [.clipShape(shape: .circle, child: .text("A"))])
    }

    @Test func parsesChainedModifiers() throws {
        let nodes = try SwiftUIParser.parse(#"Text("A").padding(8).cornerRadius(4)"#)
        #expect(nodes == [.cornerRadius(radius: 4, child: .padding(amount: 8, child: .text("A")))])
    }

    // MARK: - Errors

    @Test func throwsForUnsupportedView() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"Slider()"#)
        }
        guard case .unsupportedView(let name) = error else {
            Issue.record("Expected .unsupportedView, got \(error)")
            return
        }
        #expect(name == "Slider")
    }

    @Test func throwsForUnsupportedModifier() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"Text("A").opacity(0.5)"#)
        }
        guard case .unsupportedModifier(let name) = error else {
            Issue.record("Expected .unsupportedModifier, got \(error)")
            return
        }
        #expect(name == "opacity")
    }

    @Test func throwsForUnsupportedAlignmentOnVStack() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"VStack(alignment: .middle) { Text("A") }"#)
        }
        guard case .unsupportedAlignment(let name, let view) = error else {
            Issue.record("Expected .unsupportedAlignment, got \(error)")
            return
        }
        #expect(name == "middle")
        #expect(view == "VStack")
    }

    @Test func throwsForUnsupportedParameterOnFrame() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"Text("A").frame(depth: 10)"#)
        }
        guard case .unsupportedParameter(let name, let view) = error else {
            Issue.record("Expected .unsupportedParameter, got \(error)")
            return
        }
        #expect(name == "depth")
        #expect(view == "frame")
    }

    @Test func throwsForBackgroundWithNonColorType() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(##"Text("A").background(Gradient(hex: "#FFFFFF"))"##)
        }
        guard case .unsupportedParameter(let name, let view) = error else {
            Issue.record("Expected .unsupportedParameter, got \(error)")
            return
        }
        #expect(name == "Gradient")
        #expect(view == "background")
    }

    @Test func throwsForClipShapeWithUnsupportedShape() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"Text("A").clipShape(.roundedRectangle)"#)
        }
        guard case .unsupportedParameter(let name, let view) = error else {
            Issue.record("Expected .unsupportedParameter, got \(error)")
            return
        }
        #expect(name == "roundedRectangle")
        #expect(view == "clipShape")
    }

    @Test func throwsUnexpectedTokenWhenMissingClosingBrace() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"VStack { Text("A")"#)
        }
        guard case .unexpectedEndOfInput = error else {
            Issue.record("Expected .unexpectedEndOfInput, got \(error)")
            return
        }
    }

    @Test func throwsUnexpectedTokenWhenMissingParenthesis() throws {
        let error = try #require(throws: SwiftUIParserError.self) {
            try SwiftUIParser.parse(#"Text "A")"#)
        }
        guard case .unexpectedToken = error else {
            Issue.record("Expected .unexpectedToken, got \(error)")
            return
        }
    }
}
