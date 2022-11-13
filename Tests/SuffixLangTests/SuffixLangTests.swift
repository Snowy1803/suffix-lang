import XCTest
@testable import SuffixLang

final class SuffixLangTests: XCTestCase {
    
    func testParsingNormalFloats() {
        parseAFloat(text: "2.0", expected: 2.0)
        parseAFloat(text: "2.069", expected: 2.069)
        parseAFloat(text: "2.125", expected: 2.125)
//        parseAFloat(text: "-789.37", expected: -789.37)
        parseAFloat(text: "1 024 768.2", expected: 1024768.2)
        parseAFloat(text: "1_024 768.2", expected: 1024768.2)
        parseAFloat(text: "1   0 24 76  8  .  2 3 5", expected: 1024768.235)
        parseAFloat(text: "1___0_24_76__8__.2   35", expected: 1024768.235)
    }
    
    func parseAFloat(text: String, expected: Double) {
        let lexer = Lexer(document: text)
        let stream = TokenStream(tokens: lexer.parseDocument())
        let value = Value(stream: stream)
        
        XCTAssert(stream.isExhausted)
        XCTAssert(stream.diagnostics.isEmpty)
        if case .float(let floatValue) = value {
            XCTAssertEqual(floatValue.float, expected, accuracy: 1e-6)
        } else {
            XCTFail("Expected to parse a float")
        }
    }
    
    func testParsingNormalIntegers() {
        parseAnInteger(text: "2", expected: 2)
        parseAnInteger(text: "10253739", expected: 10253739)
//        parseAnInteger(text: "-578", expected: -578)
        parseAnInteger(text: "1 024 768", expected: 1024768)
        parseAnInteger(text: "1_024 768", expected: 1024768)
        parseAnInteger(text: "   1      0  2 4 7 6  8    ", expected: 1024768)
    }
    
    func parseAnInteger(text: String, expected: Int) {
        let lexer = Lexer(document: text)
        let stream = TokenStream(tokens: lexer.parseDocument())
        let value = Value(stream: stream)
        
        XCTAssert(stream.isExhausted)
        XCTAssert(stream.diagnostics.isEmpty)
        if case .int(let intValue) = value {
            XCTAssertEqual(intValue.integer, expected)
        } else {
            XCTFail("Expected to parse an int")
        }
    }
    
    func testParsingStringLiterals() {
        parseAStringLiteral(text: #""""#, expected: [])
        parseAStringLiteral(text: #""Hello, world!""#, expected: [.literal("Hello, world!")])
        parseAStringLiteral(text: #""Hello,\nworld!""#, expected: [.literal("Hello,"), .escaped("\\n"), .literal("world!")])
        parseAStringLiteral(text: #""\t%.2f""#, expected: [.escaped("\\t"), .percent("%.2f")])
    }
    
    func parseAStringLiteral(text: String, expected: [Token.StringComponent]) {
        let lexer = Lexer(document: text)
        let stream = TokenStream(tokens: lexer.parseDocument())
        let value = Value(stream: stream)
        
        XCTAssert(stream.isExhausted)
        XCTAssert(stream.diagnostics.isEmpty)
        if case .string(let strValue) = value,
           case .interpolation(let components) = strValue.token.data {
            XCTAssertEqual(components, expected)
        } else {
            XCTFail("Expected to parse a string literal")
        }
    }
}
