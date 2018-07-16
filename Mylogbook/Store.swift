
import CoreStore

// MARK: Store

class Store {
    
    private static var _shared: Store?
    
    static var shared: Store {
        if _shared == nil { _shared = Store() }
        
        return _shared!
    }
    
    var stack: DataStack!
    
    // MARK: Initalizers
    
    private init() {
        let id = Keychain.shared.get(.id)!
        
        let stack = DataStack(xcodeModelName: "Mylogbook")
        
        let store = SQLiteStore(fileName: "Mylogbook\(id).sqlite")
        
        try! stack.addStorageAndWait(store)
        
        self.stack = stack
    }
    
    // MARK: Reset
    
    static func reset() {
        _shared = nil
    }
}

