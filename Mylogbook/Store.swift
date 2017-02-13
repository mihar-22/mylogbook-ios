
import CoreStore

// MARK: Store

class Store {
    static let shared = Store()
    
    let stack: DataStack = {
        let stack = DataStack(modelName: "Mylogbook")
        
        try! stack.addStorageAndWait()
        
        return stack
    }()
    
    // MARK: Initalizers
    
    private init() {}
}

