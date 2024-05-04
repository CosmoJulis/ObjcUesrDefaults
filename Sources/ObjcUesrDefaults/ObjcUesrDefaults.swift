// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

protocol OptionalProtocol {
    static func wrappedType() -> Any.Type
    func wrappedType() -> Any.Type
}

extension Optional: OptionalProtocol {
    static func wrappedType() -> Any.Type { return Wrapped.self }
    func wrappedType() -> Any.Type { return Wrapped.self }
}

extension UserDefaults {
    func containsKey(_ key: String) -> Bool {
        return dictionaryRepresentation().keys.contains(key)
    }
}

open class ObjcSharedObject : NSObject {
    
    open func bind() {
        // Override it
    }
    
    public required override init() {
        super.init()
        appendClass()
        bind()
    }
    
    deinit {
        cancelAllBinds()
        removeClass()
    }
    
    @discardableResult
    func bind<T, D>(_ label: String, _ keyPath: KeyPath<T, D>) -> T where T : ObjcSharedObject {
        bingKeyPath(label, keyPath)
        return self as! T
    }
    
    @discardableResult
    func bindPart<T>(_ this: T, _ part: [String: PartialKeyPath<T>]) -> T where T : ObjcSharedObject {
        for (label,keyPath) in part {
            bingPartialKeyPath(this, label, keyPath)
        }
        return this
    }
    
    @discardableResult
    func cancelBind<T, D>(_ keyPath: KeyPath<T, D>) -> T where T : ObjcSharedObject {
        return cancelBind(NSExpression(forKeyPath: keyPath).keyPath) as! T
    }
    
    @discardableResult
    func cancelBinds(_ labels: [String]) -> Self {
        labels.forEach { cancelBind($0) }
        return self
    }
    
    @discardableResult
    func cancelBind(_ label: String) -> Self {
        cancellables[label]?.cancel()
        return self
    }
    
    func cancelAllBinds() {
        cancellables.forEach{ $1.cancel() }
    }
    
    private func bingKeyPath<T, D>(_ label: String, _ keyPath: KeyPath<T, D>) where T : ObjcSharedObject {

        let wrappedType = (D.self as? OptionalProtocol.Type)?.wrappedType()
        let isOptObjcSharedObject = wrappedType is ObjcSharedObject.Type
        
        if D.self is ObjcSharedObject.Type || isOptObjcSharedObject
             {
            
            if let cancel = cancellables[label] { cancel.cancel() }
            
            let userDefault = UserDefaults.standard
            let fullPath = String(reflecting: isOptObjcSharedObject ? wrappedType!.self : D.self)
            let storeKey = String(reflecting: type(of: self)) + "." + label
            
//            print("storeKey \(storeKey)")
//            print("fullPath \(fullPath)")
//            print("keyPath \(type(of:keyPath))")
            
            if isOptObjcSharedObject && userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                let dWrappedType = wrappedType as! ObjcSharedObject.Type
                setValue(dWrappedType.init(), forKey: label)
            }
            
            cancellables[label] = (self as! T).publisher(for: keyPath).dropFirst().sink() {
                [weak self] newValue in
                self?.assertNotDirty()
                if newValue is ObjcSharedObject || (newValue as? OptionalProtocol)?.wrappedType() is ObjcSharedObject {
                    userDefault.setValue("<" + fullPath + ">", forKey: storeKey)
                } else {
                    userDefault.setValue(nil, forKey: storeKey)
                    userDefault.dictionaryRepresentation().keys.filter{ $0.hasPrefix(fullPath + ".") }.forEach{
                        userDefault.setValue(nil, forKey: $0)
                    }
                }
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        } else {
            if let this = self as? T {
                bingPartialKeyPath(this, label, keyPath)
            } else { // Never run
                assert(false, "Self do not have this KeyPath: \(keyPath)")
            }
        }
    }

    private func bingPartialKeyPath<T>(_ this: T, _ label: String, _ keyPath: PartialKeyPath<T>) where T : ObjcSharedObject {
        
        if let cancel = cancellables[label] { cancel.cancel() }

        let userDefault = UserDefaults.standard
        let storeKey = String(reflecting: type(of: this)) + "." + label
        
//        print("storeKey \(storeKey)")
//        print("keyPath \(type(of:keyPath))")
        
        switch keyPath {
        case let kp as KeyPath<T, String>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.string(forKey: storeKey) ?? "", forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                [weak self] newValue in
                self?.assertNotDirty()
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, String?>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.string(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                [weak self] newValue in
                self?.assertNotDirty()
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue ?? "nil") (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, Int>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.integer(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                [weak self] newValue in
                self?.assertNotDirty()
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, Double>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.double(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                [weak self] newValue in
                self?.assertNotDirty()
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, Bool>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.bool(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                [weak self] newValue in
                self?.assertNotDirty()
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        default:
            assert(false, "Has not implement this Type: \(keyPath)")
        }
    }
    
    private lazy var cancellables = [String:Cancellable]()
    
    private static var classTokens = [String:Int]()

    private func removeClass() {
        let classString = NSStringFromClass(Self.self)
        if containsClass() {
            Self.classTokens[classString]! -= 1
        }
    }

    private func appendClass() {
        let classString = NSStringFromClass(Self.self)
        if containsClass() {
            Self.classTokens[classString]! += 1
        } else {
            Self.classTokens[classString] = 1
        }
    }

    private func containsClass() -> Bool {
        return Self.classTokens[NSStringFromClass(Self.self)] ?? 0 > 0
    }

    private func isDirtyClass() -> Bool {
        return Self.classTokens[NSStringFromClass(Self.self)] ?? 0 > 1
    }

    private func assertNotDirty() {
        assert(!isDirtyClass(), "Deinit the previous instance of the class \(String(reflecting: Self.self)), then create a new instance with the updated key value.")
    }
        
}


/*
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

 */
