
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
        
        // Superview of superview since text fields are within stack views that contain their error
        if let nextTextField = textField.superview?.superview?.viewWithTag(nextTag) as? UITextField {
            let _ = nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
}

// MARK: Text Field

class TextField: JVFloatLabeledTextField {
    private let inputLine = CALayer()
    
    private var isDirty = false

    var isValid = false {
        didSet {
            styleUpdate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        addInputLine()
        
        addTarget(self, action: #selector(editingChangedHandler), for: .editingChanged)
        
        styleNormal()
    }
    
    // MARK: Layers + Subviews
    
    private func addInputLine() {
        inputLine.backgroundColor = DarkTheme.base(.divider).uiColor.cgColor
        
        inputLine.frame = CGRect(x: 0, y: bounds.height - 1.0, width: bounds.width, height: 2)
        
        layer.addSublayer(inputLine)
    }
    
    // MARK: Target Handlers
    
    @objc private func editingChangedHandler() {
        if !isDirty { isDirty = true }
    }
    
    // MARK: Responder Handlers
    
    override func becomeFirstResponder() -> Bool {
        if isValid || (!isDirty && isValid) { styleFocused() }
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if isValid || (!isDirty && isValid) { styleNormal() }
        
        return super.resignFirstResponder()
    }
    
    // MARK: Styling
    
    private func styleUpdate() {
        if (!isValid) {
            styleError()
        } else if isFirstResponder {
            styleFocused()
        } else {
            styleNormal()
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
