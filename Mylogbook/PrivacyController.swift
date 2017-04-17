
import UIKit

class PrivacyController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {        
        let url = Bundle.main.url(forResource: "privacy-policy", withExtension: "html")!
        
        let html = try! String(contentsOf: url)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}
