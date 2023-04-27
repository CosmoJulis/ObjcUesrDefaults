# Supported Types

* String/String?
* Int
* Double
* Bool
* ObjcUserDefault/ObjcUserDefault?

# Example

````
// Example:

class A : ObjcUserDefault {

    @objc dynamic var name: String?
    @objc dynamic var age: Int = 0
    @objc dynamic var gender: String?
    
    override func bind() {
        bind_part(self, [
            "name": \.name,
            "age": \.age
        ])
    }
}

class B : A {

    @objc dynamic var title: String?
    
    override func bind() {
        super.bind()
        bind_part(self, [
            "age": \.age,
            "title": \.title,
            "gender": \.gender
        ])
    }
}

let a = A()
a.name = "Cosmo"  // UserDefault.standard store string "Cosmo" for "Module.A.name"
a.name = nil 
a.name = "Julis"
a.age = 15
a.age = 12

let b = B()
b.title = "level 2"
b.title = nil
b.gender = "girl"
b.gender = "boy"

--------------------------------------------------------------------------------

class A : ObjcUserDefault {
    @objc dynamic var age: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var title: String?
    
    @objc dynamic var ab: A_B?
    @objc dynamic var ac: A_C = A_C()
        
    override func bind() {
        bind_part(self, [
            "age": \.age,
            "name": \.name,
            "title": \.title
        ])
        .bind("ab", \A.ab)
        .bind("ac", \A.ac)

    }
    
    
    class A_B : ObjcUserDefault {
        @objc dynamic var level: Int = 0
        @objc dynamic var height: Double = 0.0
        @objc dynamic var title: String = ""
        @objc dynamic var gender: String?
        
        override func bind() {
            bind_part(self, [
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
    
    class A_C : ObjcUserDefault {
        @objc dynamic var title: String = ""
    }
}

let a = A()
a.ab = A.A_B()
a.ab?.level = 2
a.ab?.height = 180
print("aab:\(a.ab!)")
a.ab = nil
print("aab:\(String(describing: a.ab))")
a.ab = A.A_B()
print("aab:\(a.ab!)")


````

# Installation

Copy and Paste
