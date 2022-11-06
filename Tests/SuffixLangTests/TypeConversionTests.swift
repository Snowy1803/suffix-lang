import XCTest
@testable import Sema

final class TypeConversionTests: XCTestCase {
    let any = AnyType()
    let bool = EnumType.bool
    let int = IntType()
    let float = FloatType()
    let str = StringType()
    
    func testMiscConversion() {
        XCTAssertTrue(bool.canBeAssigned(to: bool))
        XCTAssertFalse(bool.canBeAssigned(to: int))
        XCTAssertFalse(int.canBeAssigned(to: bool))
        XCTAssertFalse(float.canBeAssigned(to: bool))
        XCTAssertTrue(bool.canBeAssigned(to: any))
        XCTAssertTrue(int.canBeAssigned(to: any))
        XCTAssertFalse(any.canBeAssigned(to: int))
    }
    
    // (str, any) (int) is convertible to (str, bool) (any)
    func testFunctionConversion() {
        let test0 = FunctionType(arguments: [.init(type: str), .init(type: any)], returning: [.init(type: int)])
        let copy0 = FunctionType(arguments: [.init(type: str), .init(type: any)], returning: [.init(type: int)])
        let test1 = FunctionType(arguments: [.init(type: str), .init(type: bool)], returning: [.init(type: any)])
        let test2 = FunctionType(arguments: [.init(type: str), .init(type: any)], returning: [.init(type: any)])
        let test3 = FunctionType(arguments: [.init(type: str), .init(type: bool)], returning: [.init(type: int)])
        let noret = FunctionType(arguments: [.init(type: str), .init(type: any)], returning: [])
        let less0 = FunctionType(arguments: [.init(type: str)], returning: [.init(type: int)])
        
        XCTAssertTrue(test0.canBeAssigned(to: copy0))
        XCTAssertTrue(test0.canBeAssigned(to: test1))
        XCTAssertFalse(test1.canBeAssigned(to: test0))
        XCTAssertTrue(test0.canBeAssigned(to: test2))
        XCTAssertFalse(test2.canBeAssigned(to: test0))
        XCTAssertTrue(test0.canBeAssigned(to: test3))
        XCTAssertFalse(test3.canBeAssigned(to: test0))
        XCTAssertFalse(test0.canBeAssigned(to: noret))
        XCTAssertFalse(test3.canBeAssigned(to: less0))
    }
    
    // (str, any..., int) (int) is convertible to (str, bool, int, float, int) (any)
    func testVariadicFunctionConversion() {
        let variadic0 = FunctionType(
            arguments: [.init(type: str), .init(type: any, variadic: true), .init(type: int)],
            returning: [.init(type: int)])
        let copy0 = FunctionType(
            arguments: [.init(type: str), .init(type: any, variadic: true), .init(type: int)],
            returning: [.init(type: int)])
        let variadic1 = FunctionType(
            arguments: [.init(type: str), .init(type: bool, variadic: true), .init(type: int)],
            returning: [.init(type: int)])
        let variadic2 = FunctionType(
            arguments: [.init(type: str), .init(type: any), .init(type: int, variadic: true)],
            returning: [.init(type: int)])
        let variadic3 = FunctionType(
            arguments: [.init(type: any, variadic: true)],
            returning: [.init(type: int)])
        let concrete = FunctionType(
            arguments: [.init(type: str), .init(type: bool), .init(type: int), .init(type: float), .init(type: int)],
            returning: [.init(type: int)])
        let minimum = FunctionType(
            arguments: [.init(type: str), .init(type: int)],
            returning: [.init(type: any)])
        let less = FunctionType(
            arguments: [.init(type: str)],
            returning: [.init(type: int)])
        
        XCTAssertTrue(variadic0.canBeAssigned(to: copy0))
        XCTAssertTrue(variadic0.canBeAssigned(to: variadic1))
        XCTAssertFalse(variadic0.canBeAssigned(to: variadic2))
        XCTAssertFalse(variadic0.canBeAssigned(to: variadic3))
        XCTAssertFalse(variadic3.canBeAssigned(to: variadic0))
        XCTAssertTrue(variadic0.canBeAssigned(to: concrete))
        XCTAssertFalse(concrete.canBeAssigned(to: variadic0))
        XCTAssertFalse(variadic0.canBeAssigned(to: less))
        XCTAssertFalse(less.canBeAssigned(to: variadic0))
        XCTAssertTrue(variadic0.canBeAssigned(to: minimum))
    }
}
