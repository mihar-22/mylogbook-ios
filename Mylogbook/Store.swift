
import CoreStore

// MARK: Store

class Store {
    static let shared = Store()
    
    let stack: DataStack = {
        let id = Keychain.shared.id!
        
        let stack = DataStack(modelName: "Mylogbook")
        
        let store = SQLiteStore(fileName: "Mylogbook\(id).sqlite")
        
        try! stack.addStorageAndWait(store)
        
        return stack
    }()
    
    // MARK: Initalizers
    
    private init() {}
}

