
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
            ObjcSharedObject.classTokens[classString]! -= 1
        }
    }

    private func appendClass() {
        let classString = NSStringFromClass(Self.self)
        if containsClass() {
            ObjcSharedObject.classTokens[classString]! += 1
        } else {
            ObjcSharedObject.classTokens[classString] = 1
        }
    }

    private func containsClass() -> Bool {
        return ObjcSharedObject.classTokens[NSStringFromClass(Self.self)] ?? 0 > 0
    }

    private func isDirtyClass() -> Bool {
        return ObjcSharedObject.classTokens[NSStringFromClass(Self.self)] ?? 0 > 1
    }

    private func assertNotDirty() {
        assert(!isDirtyClass(), "Deinit the previous instance of the class \(String(reflecting: Self.self)), then create a new instance with the updated key value.")
    }
        
}
