import XCTest
@testable import Sema

final class TypeConversionTests: XCTestCase {
    let any = AnyType.shared
    let bool = EnumType.bool
    let int = IntType.shared
    let float = FloatType.shared
    let str = StringType.shared
    
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
        let arrSd = FunctionType(arguments: [.init(type: ArrayType(element: any))], returning: [.init(type: str)])
        let arrS2 = FunctionType(arguments: [.init(type: ArrayType(element: any))], returning: [.init(type: str)])
        
        XCTAssertTrue(test0.canBeAssigned(to: copy0))
        XCTAssertTrue(test0.canBeAssigned(to: test1))
        XCTAssertFalse(test1.canBeAssigned(to: test0))
        XCTAssertTrue(test0.canBeAssigned(to: test2))
        XCTAssertFalse(test2.canBeAssigned(to: test0))
        XCTAssertTrue(test0.canBeAssigned(to: test3))
        XCTAssertFalse(test3.canBeAssigned(to: test0))
        XCTAssertFalse(test0.canBeAssigned(to: noret))
        XCTAssertFalse(test3.canBeAssigned(to: less0))
        XCTAssertTrue(arrSd.canBeAssigned(to: arrS2))
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
    
    func testArrayConversion() {
        let anyArr = ArrayType(element: any)
        let strArr = ArrayType(element: str)
        let anyAr2 = ArrayType(element: any)
        
        XCTAssertTrue(strArr.canBeAssigned(to: anyArr))
        XCTAssertTrue(anyArr.canBeAssigned(to: anyArr))
        XCTAssertTrue(anyArr.canBeAssigned(to: anyAr2))
        XCTAssertFalse(anyArr.canBeAssigned(to: strArr))
        XCTAssertFalse(strArr.canBeAssigned(to: str))
        XCTAssertFalse(str.canBeAssigned(to: strArr))
    }
    
}

extension FunctionType {
    convenience init(arguments: [Argument], returning: [Argument]) {
        self.init(arguments: arguments, returning: returning, traits: TraitContainer(type: .func, source: false, builtin: []))
    }
}
