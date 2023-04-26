import Combine

extension UserDefaults {
    func containsKey(_ key: String) -> Bool {
        return dictionaryRepresentation().keys.contains(key)
    }
}

class ObjcUserDefault : NSObject {
    
    var cancellables: [String:Cancellable] = [String:Cancellable]()

    override init() {
        super.init()
        bindKeyPath()
    }
    
    deinit {
        cancellables.forEach{$1.cancel()}
    }
    
    func bindKeyPath<T>(_ this: T, _ send: [String: PartialKeyPath<T>]) where T : NSObject {
        let userDefault = UserDefaults.standard
        let thisPath = String(describing: this).components(separatedBy: ":").first!.replacingOccurrences(of: "<", with: "")
        for (label,keyPath) in send {
            if let cancel = cancellables[label] { cancel.cancel() }
            let fullKey = thisPath + "." + label
//            print("path \(fullKey)")

            switch keyPath {
            case let kp as WritableKeyPath<T, String>:
                if userDefault.containsKey(fullKey) && !cancellables.keys.contains(label) {
                    this.setValue(userDefault.string(forKey: fullKey) ?? "", forKey: label)
                }
                cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                    newValue in
                    userDefault.setValue(newValue, forKey: fullKey)
//                    print("newValue:\(newValue)")
                }
            case let okp as WritableKeyPath<T, String?>:
                if userDefault.containsKey(fullKey) && !cancellables.keys.contains(label) {
                    this.setValue(userDefault.string(forKey: fullKey), forKey: label)
                }
                cancellables[label] = this.publisher(for: okp).dropFirst().sink() {
                    newValue in
                    userDefault.setValue(newValue, forKey: fullKey)
//                    print("newValue:\(newValue ?? "nil")")
                }
            case let kp as WritableKeyPath<T, Int>:
                if userDefault.containsKey(fullKey) && !cancellables.keys.contains(label) {
                    this.setValue(userDefault.integer(forKey: fullKey), forKey: label)
                }
                cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                    newValue in
                    userDefault.setValue(newValue, forKey: fullKey)
//                    print("newValue:\(newValue)")
                }
            case let kp as WritableKeyPath<T, Double>:
                if userDefault.containsKey(fullKey) && !cancellables.keys.contains(label) {
                    this.setValue(userDefault.double(forKey: fullKey), forKey: label)
                }
                cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                    newValue in
                    userDefault.setValue(newValue, forKey: fullKey)
//                    print("newValue:\(newValue)")
                }
            case let kp as WritableKeyPath<T, Bool>:
                if userDefault.containsKey(fullKey) && !cancellables.keys.contains(label) {
                    this.setValue(userDefault.bool(forKey: fullKey), forKey: label)
                }
                cancellables[label] = this.publisher(for: kp).dropFirst().sink() {
                    newValue in
                    userDefault.setValue(newValue, forKey: fullKey)
//                    print("newValue:\(newValue)")
                }
            default:
                assert(false, "Has not implement this Type: \(keyPath)")
            }
        }
    }
    
    func bindKeyPath() {
        // Override it
    }
}
