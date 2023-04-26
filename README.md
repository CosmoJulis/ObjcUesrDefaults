# Supported Types

* String/String?
* Int
* Double
* Bool

# Example

````
// Example:

class A : ObjcUserDefault {

    @objc dynamic var name: String?
    @objc dynamic var age: Int = 0
    @objc dynamic var gender: String?
    
    override func bindKeyPath() {
        bindKeyPath(self, [
            "name": \.name,
            "age": \.age
        ])
    }
}

class B : A {

    @objc dynamic var title: String?
    
    override func bindKeyPath() {
        super.bindKeyPath()
        bindKeyPath(self, [
            "age": \.age,
            "title": \.title,
            "gender": \.gender
        ])
    }
}


let a = A()
a.name = "Cosmo"
a.name = nil
a.name = "Julis"
a.age = 15
a.age = 12

let b = B()
b.title = "level 2"
b.title = nil
b.gender = "girl"
b.gender = "boy"

````

# Installation

Copy and Paste

# TODO

* Nested class support
