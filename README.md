# Supported Types

* String/String?
* Data/Data?
* Int
* Double
* Bool
* ObjcSharedObject/ObjcSharedObject?

# Example

````
// Example:

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

--------------------------------------------------------------------------------

class A : ObjcSharedObject {
    @objc dynamic var age: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var title: String?
    
    @objc dynamic var ab: A_B?
    @objc dynamic var ac: A_C = A_C()
        
    override func bind() {
        bindPart(self, [
            "age": \.age,
            "name": \.name,
            "title": \.title
        ])
        .bind("ab", \A.ab)
        .bind("ac", \A.ac)

    }
    
    
    class A_B : ObjcSharedObject {
        @objc dynamic var level: Int = 0
        @objc dynamic var height: Double = 0.0
        @objc dynamic var title: String = ""
        @objc dynamic var gender: String?
        
        override func bind() {
            bindPart(self, [
                "level":\.level,
                "height":\.height,
                "title":\.title,
                "gender":\.gender
            ])
        }
        
        override var description: String {
            return String("level:\(level), height:\(height), title:\(title), gender:\(gender)")
        }
        
    }
    
    class A_C : ObjcSharedObject {
        @objc dynamic var title: String = ""
    }
}

let a = A()

a.ab = A.A_B()          // ab = Optional(level:0, height:0.0, title:, gender:nil) (at:"test.A.ab")
a.ab?.level = 2         // level = 2 (at:"test.A.A_B.level")
a.ab?.height = 180      // height = 180.0 (at:"test.A.A_B.height")
print("aab:\(a.ab!)")   // aab:level:2, height:180.0, title:, gender:nil

a.ab = nil              // ab = nil (at:"test.A.ab")
print("aab:\(String(describing: a.ab))") // aab:nil

a.ab = A.A_B()          // ab = Optional(level:0, height:0.0, title:, gender:nil) (at:"test.A.ab")
print("aab:\(a.ab!)")   // aab:level:0, height:0.0, title:, gender:nil

--------------------------------------------------------------------------------

class A : ObjcSharedObject {

    @objc dynamic var name: String?
    
    override func bind() {
        bindPart(self, [
            "name": \.name,
        ])
    }
}

var a: A? = A()
a?.name = "Cosmo"

let a2 = A()
a2.name = "Julis"       // Assertion failed: Deinit the previous instance of the class test.A, 
                        // then create a new instance with the updated key value.

// a2.name = "Julis"
a = nil
a2.name = "Julis"       // name = Julis (at:"test.A.name")

````

# Installation

Copy and Paste

# TODO

Threadsafe
