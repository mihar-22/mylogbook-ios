
import UIKit

// MARK: Nib View

protocol NibView: class {
    var view: UIView! { get set }
    
    func initNib()

    func loadNib() -> UIView
}

extension NibView where Self: UIView {
    func initNib() {
        view = loadNib()

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
    }
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}

