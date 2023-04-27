
import Foundation
import Combine

extension UserDefaults {
    func containsKey(_ key: String) -> Bool {
        return dictionaryRepresentation().keys.contains(key)
    }
}

protocol OptionalProtocol {
    static func wrappedType() -> Any.Type
    func wrappedType() -> Any.Type
}

extension Optional: OptionalProtocol {
    static func wrappedType() -> Any.Type { return Wrapped.self }
    func wrappedType() -> Any.Type { return Wrapped.self }
}

class ObjcUserDefault : NSObject {
    
    var cancellables: [String:Cancellable] = [String:Cancellable]()

    required override init() {
        super.init()
        bind()
    }
    
    deinit {
        cancellables.forEach{$1.cancel()}
    }
    
    private func bingPartialKeyPath<T>(_ label: String, _ keyPath: PartialKeyPath<T>) where T : ObjcUserDefault {

        guard let this = self as? T else { return }

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
                newValue in
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, String?>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.string(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                newValue in
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue ?? "nil") (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, Int>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.integer(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                newValue in
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, Double>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.double(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                newValue in
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        case let kp as KeyPath<T, Bool>:
            if userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                this.setValue(userDefault.bool(forKey: storeKey), forKey: label)
            }
            cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                newValue in
                userDefault.setValue(newValue, forKey: storeKey)
                print("\(label) = \(newValue) (at:\"\(storeKey)\")")
            }
        default:
            assert(false, "Has not implement this Type: \(keyPath)")
        }
    }
    
    private func bingKeyPath<T, D>(_ label: String, _ keyPath: KeyPath<T, D>) where T : ObjcUserDefault {

        let wrappedType = (D.self as? OptionalProtocol.Type)?.wrappedType()
        let isOptObjcUserDefault = wrappedType is ObjcUserDefault.Type
        
        if D.self is ObjcUserDefault.Type || isOptObjcUserDefault
             {
            
            if let cancel = cancellables[label] { cancel.cancel() }
            
            let userDefault = UserDefaults.standard
            let fullPath = String(reflecting: isOptObjcUserDefault ? wrappedType!.self : D.self)
            let storeKey = String(reflecting: type(of: self)) + "." + label
            
//            print("storeKey \(storeKey)")
//            print("fullPath \(fullPath)")
//            print("keyPath \(type(of:keyPath))")
            
            if isOptObjcUserDefault && userDefault.containsKey(storeKey) && !cancellables.keys.contains(label) {
                let dWrappedType = wrappedType as! ObjcUserDefault.Type
                self.setValue(dWrappedType.init(), forKey: label)
            }
            
            cancellables[label] = (self as! T).publisher(for: keyPath).dropFirst().sink() {
                newValue in
                if newValue is ObjcUserDefault || (newValue as? OptionalProtocol)?.wrappedType() is ObjcUserDefault {
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
            bingPartialKeyPath(label, keyPath)
        }
    }
    
    @discardableResult
    func bind<T, D>(_ label: String, _ keyPath: KeyPath<T, D>) -> T where T : ObjcUserDefault {
        bingKeyPath(label, keyPath)
        return self as! T
    }
    
    @discardableResult
    func bind_part<T>(_ this: T, _ send: [String: PartialKeyPath<T>]) -> T where T : ObjcUserDefault {
        for (label,keyPath) in send {
            bingPartialKeyPath(label, keyPath)
        }
        return this
    }

    func bind() {
        // Override it
    }
}
