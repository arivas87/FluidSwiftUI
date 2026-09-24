import Foundation

/// Parses a small subset of SwiftUI's declarative syntax (Text, Image, VStack, HStack,
/// ZStack, Button — whose action opens a URL — and the `.padding`,
/// `.background(Color(hex:))`, `.fontSize`, `.cornerRadius`, `.tint(Color(hex:))`,
/// `.foregroundStyle(Color(hex:))`, `.frame(width:height:)`, and
/// `.clipShape(.circle)` modifiers) into a `SwiftUINode` tree that can be
/// rendered by `SwiftUICodeRenderer`.
struct SwiftUIParser {
    static func parse(_ source: String) throws -> [SwiftUINode] {
        var lexer = Lexer(source)
        let tokens = try lexer.tokenize()
        var parser = TokenParser(tokens)
        return try parser.parseStatements(until: nil)
    }
}

private struct TokenParser {
    private let tokens: [Token]
    private var index = 0

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    private func peek() -> Token? {
        index < tokens.count ? tokens[index] : nil
    }

    private mutating func advance() -> Token? {
        guard index < tokens.count else { return nil }
        let token = tokens[index]
        index += 1
        return token
    }

    mutating func parseStatements(until terminator: Token?) throws -> [SwiftUINode] {
        var nodes: [SwiftUINode] = []
        while let token = peek(), token != terminator {
            nodes.append(try parseStatementWithModifiers())
        }
        if let terminator {
            guard advance() == terminator else {
                throw SwiftUIParserError.unexpectedEndOfInput
            }
        }
        return nodes
    }

    /// Parses a view statement followed by zero or more chained `.modifier(...)` calls,
    /// e.g. `Text("Hi").padding(8).padding()`.
    private mutating func parseStatementWithModifiers() throws -> SwiftUINode {
        var node = try parseStatement()
        while peek() == .dot {
            _ = advance()
            node = try parseModifier(applyingTo: node)
        }
        return node
    }

    private mutating func parseModifier(applyingTo node: SwiftUINode) throws -> SwiftUINode {
        guard let token = advance(), case .identifier(let name) = token else {
            throw SwiftUIParserError.unexpectedToken("a modifier name")
        }

        switch name {
        case "padding":
            let amount = try parseOptionalPaddingArgument()
            return .padding(amount: amount, child: node)
        case "background":
            let hex = try parseColorHexArgument(modifier: name)
            return .background(hex: hex, child: node)
        case "fontSize":
            let size = try parseSingleNumberArgument(modifier: name)
            return .fontSize(size: size, child: node)
        case "cornerRadius":
            let radius = try parseSingleNumberArgument(modifier: name)
            return .cornerRadius(radius: radius, child: node)
        case "tint":
            let hex = try parseColorHexArgument(modifier: name)
            return .tint(hex: hex, child: node)
        case "foregroundStyle":
            let hex = try parseColorHexArgument(modifier: name)
            return .foregroundStyle(hex: hex, child: node)
        case "frame":
            let arguments = try parseFrameArguments(view: name)
            return .frame(width: arguments.width, height: arguments.height, child: node)
        case "clipShape":
            let shape = try parseClipShapeArgument(view: name)
            return .clipShape(shape: shape, child: node)
        default:
            throw SwiftUIParserError.unsupportedModifier(name)
        }
    }

    /// Parses a `()` or `(16)` argument list for the `.padding` modifier.
    private mutating func parseOptionalPaddingArgument() throws -> Double? {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        var amount: Double?
        if peek() != .rparen {
            guard let valueToken = advance(), case .number(let value) = valueToken else {
                throw SwiftUIParserError.unexpectedToken("a number for 'padding'")
            }
            amount = value
        }
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return amount
    }

    /// Parses a required `(16)` numeric argument list, e.g. for the `.fontSize` modifier.
    private mutating func parseSingleNumberArgument(modifier: String) throws -> Double {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        guard let valueToken = advance(), case .number(let value) = valueToken else {
            throw SwiftUIParserError.unexpectedToken("a number for '\(modifier)'")
        }
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return value
    }

    /// Parses a `(Color(hex: "#RRGGBB"))` argument list for the `.background` modifier.
    private mutating func parseColorHexArgument(modifier: String) throws -> String {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        guard let typeToken = advance(), case .identifier(let typeName) = typeToken else {
            throw SwiftUIParserError.unexpectedToken("'Color'")
        }
        guard typeName == "Color" else {
            throw SwiftUIParserError.unsupportedParameter(typeName, view: modifier)
        }
        let hex = try parseNamedStringArgument("hex", view: typeName)
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return hex
    }

    /// Parses a `(width: 100, height: 100)` argument list for the `.frame` modifier. Both
    /// arguments are optional and may appear in either order.
    private mutating func parseFrameArguments(view: String) throws -> (width: Double?, height: Double?) {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }

        var width: Double?
        var height: Double?

        if peek() != .rparen {
            while true {
                guard let token = advance(), case .identifier(let parameterName) = token else {
                    throw SwiftUIParserError.unexpectedToken("a parameter name")
                }
                guard advance() == .colon else { throw SwiftUIParserError.unexpectedToken(":") }
                guard let valueToken = advance(), case .number(let value) = valueToken else {
                    throw SwiftUIParserError.unexpectedToken("a number for '\(parameterName)'")
                }

                switch parameterName {
                case "width":
                    width = value
                case "height":
                    height = value
                default:
                    throw SwiftUIParserError.unsupportedParameter(parameterName, view: view)
                }

                if peek() == .comma {
                    _ = advance()
                    continue
                }
                break
            }
        }

        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return (width, height)
    }

    /// Parses a `(.circle)` argument list for the `.clipShape` modifier.
    private mutating func parseClipShapeArgument(view: String) throws -> ClipShapeValue {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        guard advance() == .dot else { throw SwiftUIParserError.unexpectedToken(".") }
        guard let valueToken = advance(), case .identifier(let caseName) = valueToken else {
            throw SwiftUIParserError.unexpectedToken("a shape case")
        }
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }

        switch caseName {
        case "circle":
            return .circle
        default:
            throw SwiftUIParserError.unsupportedParameter(caseName, view: view)
        }
    }

    private mutating func parseStatement() throws -> SwiftUINode {
        guard let token = advance(), case .identifier(let name) = token else {
            throw SwiftUIParserError.unexpectedToken("expected a view name")
        }

        switch name {
        case "Text":
            return .text(try parseSingleStringArgument())
        case "Image":
            return .image(url: try parseNamedStringArgument("url", view: name))
        case "VStack":
            let arguments = try parseStackArguments(view: name)
            let alignment: HorizontalAlignmentValue
            switch arguments.alignmentName {
            case nil: alignment = .center
            case "leading": alignment = .leading
            case "center": alignment = .center
            case "trailing": alignment = .trailing
            case .some(let other):
                throw SwiftUIParserError.unsupportedAlignment(other, view: name)
            }
            let children = try parseChildren()
            return .vstack(alignment: alignment, spacing: arguments.spacing, children: children)
        case "HStack":
            let arguments = try parseStackArguments(view: name)
            let alignment: VerticalAlignmentValue
            switch arguments.alignmentName {
            case nil: alignment = .center
            case "top": alignment = .top
            case "center": alignment = .center
            case "bottom": alignment = .bottom
            case .some(let other):
                throw SwiftUIParserError.unsupportedAlignment(other, view: name)
            }
            let children = try parseChildren()
            return .hstack(alignment: alignment, spacing: arguments.spacing, children: children)
        case "ZStack":
            let alignmentName = try parseAlignmentOnlyArgument(view: name)
            let alignment: AlignmentValue
            switch alignmentName {
            case nil: alignment = .center
            case "topLeading": alignment = .topLeading
            case "top": alignment = .top
            case "topTrailing": alignment = .topTrailing
            case "leading": alignment = .leading
            case "center": alignment = .center
            case "trailing": alignment = .trailing
            case "bottomLeading": alignment = .bottomLeading
            case "bottom": alignment = .bottom
            case "bottomTrailing": alignment = .bottomTrailing
            case .some(let other):
                throw SwiftUIParserError.unsupportedAlignment(other, view: name)
            }
            let children = try parseChildren()
            return .zstack(alignment: alignment, children: children)
        case "Button":
            let arguments = try parseStringAndNamedStringArgument("url", view: name)
            return .button(title: arguments.string, url: arguments.namedValue)
        default:
            throw SwiftUIParserError.unsupportedView(name)
        }
    }

    private mutating func parseSingleStringArgument() throws -> String {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        guard let token = advance(), case .string(let value) = token else {
            throw SwiftUIParserError.unexpectedToken("a string literal")
        }
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return value
    }

    /// Parses a `(parameterName: "value")` argument list containing a single required
    /// named string argument, e.g. `Image(url: "https://example.com/photo.png")`.
    private mutating func parseNamedStringArgument(_ parameterName: String, view: String) throws -> String {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        guard let nameToken = advance(), case .identifier(let foundName) = nameToken else {
            throw SwiftUIParserError.unexpectedToken("a parameter name")
        }
        guard foundName == parameterName else {
            throw SwiftUIParserError.unsupportedParameter(foundName, view: view)
        }
        guard advance() == .colon else { throw SwiftUIParserError.unexpectedToken(":") }
        guard let valueToken = advance(), case .string(let value) = valueToken else {
            throw SwiftUIParserError.unexpectedToken("a string literal for '\(parameterName)'")
        }
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return value
    }

    /// Parses a `("value", parameterName: "value")` argument list containing a required
    /// positional string followed by a required named string argument, e.g.
    /// `Button("Open", url: "https://example.com")`.
    private mutating func parseStringAndNamedStringArgument(
        _ parameterName: String,
        view: String
    ) throws -> (string: String, namedValue: String) {
        guard advance() == .lparen else { throw SwiftUIParserError.unexpectedToken("(") }
        guard let stringToken = advance(), case .string(let string) = stringToken else {
            throw SwiftUIParserError.unexpectedToken("a string literal")
        }
        guard advance() == .comma else { throw SwiftUIParserError.unexpectedToken(",") }
        guard let nameToken = advance(), case .identifier(let foundName) = nameToken else {
            throw SwiftUIParserError.unexpectedToken("a parameter name")
        }
        guard foundName == parameterName else {
            throw SwiftUIParserError.unsupportedParameter(foundName, view: view)
        }
        guard advance() == .colon else { throw SwiftUIParserError.unexpectedToken(":") }
        guard let valueToken = advance(), case .string(let namedValue) = valueToken else {
            throw SwiftUIParserError.unexpectedToken("a string literal for '\(parameterName)'")
        }
        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return (string, namedValue)
    }

    /// Parses an optional `(alignment: .xxx, spacing: 8)` argument list. Both arguments are
    /// optional and may appear in any order; the argument list itself may be omitted entirely.
    private mutating func parseStackArguments(view: String) throws -> (alignmentName: String?, spacing: Double?) {
        guard peek() == .lparen else { return (nil, nil) }
        _ = advance()

        var alignmentName: String?
        var spacing: Double?

        if peek() != .rparen {
            while true {
                guard let token = advance(), case .identifier(let parameterName) = token else {
                    throw SwiftUIParserError.unexpectedToken("a parameter name")
                }
                guard advance() == .colon else { throw SwiftUIParserError.unexpectedToken(":") }

                switch parameterName {
                case "spacing":
                    guard let valueToken = advance(), case .number(let value) = valueToken else {
                        throw SwiftUIParserError.unexpectedToken("a number for 'spacing'")
                    }
                    spacing = value
                case "alignment":
                    guard advance() == .dot else { throw SwiftUIParserError.unexpectedToken(".") }
                    guard let valueToken = advance(), case .identifier(let caseName) = valueToken else {
                        throw SwiftUIParserError.unexpectedToken("an alignment case")
                    }
                    alignmentName = caseName
                default:
                    throw SwiftUIParserError.unsupportedParameter(parameterName, view: view)
                }

                if peek() == .comma {
                    _ = advance()
                    continue
                }
                break
            }
        }

        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return (alignmentName, spacing)
    }

    /// Parses an optional `(alignment: .xxx)` argument list containing at most a single
    /// `alignment:` parameter, e.g. `ZStack(alignment: .topLeading)`.
    private mutating func parseAlignmentOnlyArgument(view: String) throws -> String? {
        guard peek() == .lparen else { return nil }
        _ = advance()

        var alignmentName: String?

        if peek() != .rparen {
            guard let token = advance(), case .identifier(let parameterName) = token else {
                throw SwiftUIParserError.unexpectedToken("a parameter name")
            }
            guard parameterName == "alignment" else {
                throw SwiftUIParserError.unsupportedParameter(parameterName, view: view)
            }
            guard advance() == .colon else { throw SwiftUIParserError.unexpectedToken(":") }
            guard advance() == .dot else { throw SwiftUIParserError.unexpectedToken(".") }
            guard let valueToken = advance(), case .identifier(let caseName) = valueToken else {
                throw SwiftUIParserError.unexpectedToken("an alignment case")
            }
            alignmentName = caseName
        }

        guard advance() == .rparen else { throw SwiftUIParserError.unexpectedToken(")") }
        return alignmentName
    }

    private mutating func parseChildren() throws -> [SwiftUINode] {
        guard advance() == .lbrace else { throw SwiftUIParserError.unexpectedToken("{") }
        return try parseStatements(until: .rbrace)
    }
}
