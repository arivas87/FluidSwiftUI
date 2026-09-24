import Testing
@testable import FluidSwiftUI

struct LexerTests {

    @Test func emptySourceProducesNoTokens() throws {
        var lexer = Lexer("")
        #expect(try lexer.tokenize() == [])
    }

    @Test func whitespaceOnlySourceProducesNoTokens() throws {
        var lexer = Lexer("   \n\t  ")
        #expect(try lexer.tokenize() == [])
    }

    @Test func tokenizesPunctuation() throws {
        var lexer = Lexer("(){}:,.")
        let tokens = try lexer.tokenize()
        #expect(tokens == [.lparen, .rparen, .lbrace, .rbrace, .colon, .comma, .dot])
    }

    @Test func tokenizesIdentifier() throws {
        var lexer = Lexer("VStack")
        #expect(try lexer.tokenize() == [.identifier("VStack")])
    }

    @Test func identifierCanContainDigitsAndUnderscoresButNotStartWithDigit() throws {
        var lexer = Lexer("_my_view2")
        #expect(try lexer.tokenize() == [.identifier("_my_view2")])
    }

    @Test func tokenizesIntegerNumber() throws {
        var lexer = Lexer("42")
        #expect(try lexer.tokenize() == [.number(42)])
    }

    @Test func tokenizesDecimalNumber() throws {
        var lexer = Lexer("3.14")
        #expect(try lexer.tokenize() == [.number(3.14)])
    }

    @Test func trailingDotAfterNumberIsNotConsumedWithoutFollowingDigit() throws {
        var lexer = Lexer("10.")
        let tokens = try lexer.tokenize()
        #expect(tokens == [.number(10), .dot])
    }

    @Test func tokenizesSimpleString() throws {
        var lexer = Lexer("\"hello\"")
        #expect(try lexer.tokenize() == [.string("hello")])
    }

    @Test func tokenizesStringWithEscapedQuote() throws {
        var lexer = Lexer("\"say \\\"hi\\\"\"")
        #expect(try lexer.tokenize() == [.string("say \"hi\"")])
    }

    @Test func unterminatedStringThrowsUnexpectedEndOfInput() throws {
        var lexer = Lexer("\"unterminated")
        let error = try #require(throws: SwiftUIParserError.self) {
            try lexer.tokenize()
        }
        guard case .unexpectedEndOfInput = error else {
            Issue.record("Expected .unexpectedEndOfInput, got \(error)")
            return
        }
    }

    @Test func stringEndingInBackslashThrowsUnexpectedEndOfInput() throws {
        var lexer = Lexer("\"trailing\\")
        let error = try #require(throws: SwiftUIParserError.self) {
            try lexer.tokenize()
        }
        guard case .unexpectedEndOfInput = error else {
            Issue.record("Expected .unexpectedEndOfInput, got \(error)")
            return
        }
    }

    @Test func unexpectedCharacterThrows() throws {
        var lexer = Lexer("#")
        let error = try #require(throws: SwiftUIParserError.self) {
            try lexer.tokenize()
        }
        guard case .unexpectedCharacter(let character) = error else {
            Issue.record("Expected .unexpectedCharacter, got \(error)")
            return
        }
        #expect(character == "#")
    }

    @Test func tokenizesCompoundExpression() throws {
        var lexer = Lexer(#"VStack(spacing: 10) { Text("Hello") }"#)
        let tokens = try lexer.tokenize()
        #expect(tokens == [
            .identifier("VStack"), .lparen, .identifier("spacing"), .colon, .number(10), .rparen,
            .lbrace, .identifier("Text"), .lparen, .string("Hello"), .rparen, .rbrace
        ])
    }

    @Test func tokenizesModifierChainWithDot() throws {
        var lexer = Lexer(".padding(8).cornerRadius(4)")
        let tokens = try lexer.tokenize()
        #expect(tokens == [
            .dot, .identifier("padding"), .lparen, .number(8), .rparen,
            .dot, .identifier("cornerRadius"), .lparen, .number(4), .rparen
        ])
    }
}
