import Foundation

enum Token: Equatable {
    case identifier(String)
    case string(String)
    case number(Double)
    case lparen, rparen, lbrace, rbrace, colon, comma, dot
}

struct Lexer {
    private let characters: [Character]
    private var index = 0

    init(_ source: String) {
        characters = Array(source)
    }

    mutating func tokenize() throws -> [Token] {
        var tokens: [Token] = []
        while let token = try nextToken() {
            tokens.append(token)
        }
        return tokens
    }

    private mutating func nextToken() throws -> Token? {
        skipWhitespace()
        guard let character = peek() else { return nil }

        switch character {
        case "(":
            index += 1
            return .lparen
        case ")":
            index += 1
            return .rparen
        case "{":
            index += 1
            return .lbrace
        case "}":
            index += 1
            return .rbrace
        case ":":
            index += 1
            return .colon
        case ",":
            index += 1
            return .comma
        case ".":
            index += 1
            return .dot
        case "\"":
            return try readString()
        default:
            if character.isNumber {
                return readNumber()
            }
            if character.isLetter || character == "_" {
                return readIdentifier()
            }
            throw SwiftUIParserError.unexpectedCharacter(character)
        }
    }

    private func peek() -> Character? {
        index < characters.count ? characters[index] : nil
    }

    private func peekNext() -> Character? {
        index + 1 < characters.count ? characters[index + 1] : nil
    }

    private mutating func skipWhitespace() {
        while let character = peek(), character.isWhitespace {
            index += 1
        }
    }

    private mutating func readIdentifier() -> Token {
        var result = ""
        while let character = peek(), character.isLetter || character.isNumber || character == "_" {
            result.append(character)
            index += 1
        }
        return .identifier(result)
    }

    private mutating func readNumber() -> Token {
        var result = ""
        while let character = peek(), character.isNumber {
            result.append(character)
            index += 1
        }
        if peek() == ".", let next = peekNext(), next.isNumber {
            result.append(".")
            index += 1
            while let character = peek(), character.isNumber {
                result.append(character)
                index += 1
            }
        }
        return .number(Double(result) ?? 0)
    }

    private mutating func readString() throws -> Token {
        index += 1 // opening quote
        var result = ""
        while let character = peek(), character != "\"" {
            if character == "\\" {
                index += 1
                guard let escaped = peek() else { throw SwiftUIParserError.unexpectedEndOfInput }
                result.append(escaped)
                index += 1
            } else {
                result.append(character)
                index += 1
            }
        }
        guard peek() == "\"" else { throw SwiftUIParserError.unexpectedEndOfInput }
        index += 1 // closing quote
        return .string(result)
    }
}
