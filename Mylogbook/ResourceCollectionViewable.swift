
import  UIKit

// MARK: Resource Collection Viewable

protocol ResourceCollectionViewable: class {
    associatedtype Model: Resourceable
    
    var collection: [Model] { get set }
    
    weak var collectionTable: UITableView! { get }

    func getCollection()
    
    func deleteModel(indexPath: IndexPath)
    
    func setupTable()

    func addToTable(_ model: Model)
    
    func removeFromTable(indexPath: IndexPath)
}

// MARK: View Controller

extension ResourceCollectionViewable where Self: UIViewController {
    
    // MARK: View Lifecycles
    
    func viewDidLoadHandler() {
        setupTable()
        
        getCollection()
    }
    
    // MARK: Networking
    
    func getCollection() {
        let route = ResourceRoute<Model>.index
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Model]>) in
            guard let collection = response.data else { return }
            
            self.collectionTable.beginUpdates()
            
            for model in collection { self.addToTable(model) }
            
            self.collectionTable.endUpdates()
        }
    }
    
    func deleteModel(indexPath: IndexPath) {
        let model = collection[indexPath.row]
        
        let route = ResourceRoute<Model>.destroy(model)
        
        Session.shared.requestJSON(route) { _ in
            self.removeFromTable(indexPath: indexPath)
        }
    }
}

// MARK: Table View - Data Source + Delegate

extension ResourceCollectionViewable where Self: UITableViewDataSource & UITableViewDelegate {
    func setupTable() {
        collectionTable.dataSource = self
        
        collectionTable.delegate = self
        
        collectionTable.tableFooterView = UIView()
    }
    
    func addToTable(_ model: Model) {
        collection.append(model)
        
        collectionTable.insertRows(at: [IndexPath(row: collection.count - 1, section: 0)], with: .automatic)
    }
    
    func removeFromTable(indexPath: IndexPath) {
        collection.remove(at: indexPath.row)
        
        collectionTable.deleteRows(at: [indexPath], with: .automatic)
    }
}
