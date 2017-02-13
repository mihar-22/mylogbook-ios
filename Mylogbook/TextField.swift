
import UIKit

// MARK: Text Field

@IBDesignable
class TextField: UIView, NibView {

    var view: UIView!
    
    var viewBottomConstraint: NSLayoutConstraint!
    
    var text: String? {
        get {
            return field.text
        }
        
        set(text) {
            field.text = text
        }
    }
    
    var error: String? {
        get {
            return errorLabel.text
        }

        set(error) {
            errorLabel.text = error
            
            update()
        }
    }
    
    // MARK: IB Inspectables
    
    @IBInspectable var placeholder: String? {
        get {
            return field.placeholder
        }
        
        set(placeholder) {
            field.placeholder = placeholder
        }
    }
    
    @IBInspectable var capitalization: Int {
        get {
            return field.autocapitalizationType.rawValue
        }
        
        set(capitalization) {
            field.autocapitalizationType = UITextAutocapitalizationType(rawValue: capitalization)!
        }
    }
    
    @IBInspectable var keyboardType: Int {
        get {
            return field.keyboardType.rawValue
        }
        
        set(keyboardType) {
            field.keyboardType = UIKeyboardType(rawValue: keyboardType)!
        }
    }
    
    @IBInspectable var returnKeyType: Int {
        get {
            return field.returnKeyType.rawValue
        }
        
        set(returnKeyType) {
            field.returnKeyType = UIReturnKeyType(rawValue: returnKeyType)!
        }
    }

    @IBInspectable var secureTextEntry: Bool {
        get {
            return field.isSecureTextEntry
        }
        
        set(isSecureTextEntry) {
            field.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var field: JVTextField!
    
    @IBOutlet weak var errorLabel: UILabel!

    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _init()
    }
    
    private func _init() {
        initNib()
        
        viewBottomConstraint = view.bottomAnchor.constraint(equalTo: field.bottomAnchor,
                                                            constant: field.inputLine.frame.height)
        
        viewBottomConstraint.isActive = true
        
        errorLabel.text = nil
    }
    
    // MARK: Layout
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: view.frame.width, height: 65)
    }
    
    // MARK: Styling
    
    private func update() {
        if error == nil {
            field.isValid = true
            
            errorLabel.isHidden = true
            
            viewBottomConstraint.isActive = true
        } else {
            field.isValid = false
            
            errorLabel.isHidden = false
            
            viewBottomConstraint.isActive = false
            
            UIView.animate(withDuration: 0.4) { self.view.layoutIfNeeded() }
        }
    }
}
