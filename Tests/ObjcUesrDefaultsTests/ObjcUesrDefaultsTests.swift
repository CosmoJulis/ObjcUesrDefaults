import XCTest
@testable import ObjcUesrDefaults

final class ObjcUesrDefaultsTests: XCTestCase {
    
    class A : ObjcSharedObject {

        @objc dynamic var name: String?
        @objc dynamic var age: Int = 0
        @objc dynamic var gender: String?
        
        override func bind() {
            bindPart(self, [
                "name": \.name,
                "age": \.age
            ])
        }
    }

    class B : A {

        @objc dynamic var title: String?
        
        override func bind() {
            super.bind()
            bindPart(self, [
                "age": \.age,
                "title": \.title,
                "gender": \.gender
            ])
        }
    }


    
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        let a = A()
        a.name = "Cosmo"    // name = Cosmo (at:"test.A.name")
        a.name = nil        // name = nil (at:"test.A.name")
        a.name = "Julis"    // name = Julis (at:"test.A.name")
        a.age = 15          // age = 15 (at:"test.A.age")
        a.age = 12          // age = 12 (at:"test.A.age")

        let b = B()
        b.title = "level 2" // title = level 2 (at:"test.B.title")
        b.title = nil       // title = nil (at:"test.B.title")
        b.gender = "girl"   // gender = girl (at:"test.B.gender")
        b.gender = "boy"    // gender = boy (at:"test.B.gender")

        let ba = b as A
        ba.gender = "girl"   // gender = girl (at:"test.B.gender")
    }
}
