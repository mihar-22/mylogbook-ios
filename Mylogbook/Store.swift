
import CoreStore

// MARK: Store

class Store {
    static let shared = Store()
    
    var stack: DataStack!
    
    // MARK: Initalizers
    
    private init() { setup() }
    
    func setup() {
        let id = Keychain.shared.get(.id)!
        
        let stack = DataStack(modelName: "Mylogbook")
        
        let store = SQLiteStore(fileName: "Mylogbook\(id).sqlite")
        
        try! stack.addStorageAndWait(store)
        
        self.stack = stack
    }
}

