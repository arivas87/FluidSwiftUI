import Foundation

enum SwiftUIParserError: Error, LocalizedError {
    case unexpectedCharacter(Character)
    case unexpectedToken(String)
    case unexpectedEndOfInput
    case unsupportedView(String)
    case unsupportedModifier(String)
    case unsupportedParameter(String, view: String)
    case unsupportedAlignment(String, view: String)

    var errorDescription: String? {
        switch self {
        case .unexpectedCharacter(let character): "Unexpected character '\(character)'"
        case .unexpectedToken(let token): "Unexpected token: \(token)"
        case .unexpectedEndOfInput: "Unexpected end of input"
        case .unsupportedView(let name): "Unsupported view '\(name)'"
        case .unsupportedModifier(let name): "Unsupported modifier '.\(name)'"
        case .unsupportedParameter(let name, let view): "Unsupported parameter '\(name)' for '\(view)'"
        case .unsupportedAlignment(let name, let view): "Unsupported alignment '.\(name)' for '\(view)'"
        }
    }
}
