
import UIKit
import JVFloatLabeledTextField

// MARK: Text Field Delegate

protocol TextFieldDelegate: UITextFieldDelegate {
    func setupTextFields() -> Void
    
    func textFieldShouldReturnHandler(_ textField: UITextField) -> Bool
}

extension TextFieldDelegate {
    func textFieldShouldReturnHandler(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextTextField = textField.superview?.superview?.superview?.viewWithTag(nextTag) as? UITextField {
            let _ = nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
}

// MARK: JVTextField

enum JVTextFieldStyle {
    case normal, focused ,error
}

@IBDesignable
class JVTextField: JVFloatLabeledTextField {
    
    let inputLine = CALayer()
    
    private var isDirty = false
    
    var isValid: Bool = true {
        didSet {
            update()
        }
    }
    
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
        addInputLine()
        
        restyle(.normal)
        
        addTarget(self, action: #selector(editingChangedHandler), for: .editingChanged)
    }
    
    // MARK: Handlers
    
    override func becomeFirstResponder() -> Bool {
        if isValid || (!isDirty && isValid) { styleFocused() }
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if isValid || (!isDirty && isValid) { styleNormal() }
        
        return super.resignFirstResponder()
    }
    
    @objc private func editingChangedHandler() {
        if !isDirty { isDirty = true }
    }
    
    // MARK: Styling

    private func addInputLine() {
        inputLine.backgroundColor = DarkTheme.base(.divider).uiColor.cgColor
        
        inputLine.frame = CGRect(x: 0, y: bounds.height - 1.0, width: bounds.width, height: 2)
        
        layer.addSublayer(inputLine)
    }
    
    private func update() {
        if (!isValid) {
            restyle(.error)
        } else if isFirstResponder {
            restyle(.focused)
        } else {
            restyle(.normal)
        }
    }
    
    func restyle(_ style: JVTextFieldStyle) {
        switch style {
        case .normal:
            styleNormal()
        case .focused:
            styleFocused()
        case .error:
            styleError()
        }
    }
    
    private func styleNormal() {
        // Floating Label
        floatingLabelTextColor = DarkTheme.base(.hint).uiColor
        floatingLabelActiveTextColor = DarkTheme.brand.uiColor
        
        // Border
        borderStyle = .none
        
        // Placeholder
        placeholderColor = DarkTheme.base(.hint).uiColor
        
        // Input
        textColor = DarkTheme.base(.primary).uiColor
        
        // Tint
        tintColor = DarkTheme.brand.uiColor
        
        // Input Line
        inputLine.backgroundColor = DarkTheme.base(.divider).uiColor.cgColor
    }
    
    private func styleFocused() {
        styleNormal()
        
        // Input Line
        inputLine.backgroundColor = DarkTheme.brand.uiColor.cgColor
    }
    
    private func styleError() {
        // Floating Label
        floatingLabelTextColor = DarkTheme.error.uiColor
        floatingLabelActiveTextColor = DarkTheme.error.uiColor
        
        // Tint
        tintColor = DarkTheme.error.uiColor
        
        // Input Line
        inputLine.backgroundColor = DarkTheme.error.uiColor.cgColor
    }
}
