
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
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
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
        inputLine.backgroundColor = Palette.seperator.uiColor.cgColor
        
        inputLine.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 1)
        
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
        floatingLabelTextColor = Palette.secondaryLight.uiColor
        floatingLabelActiveTextColor = Palette.tint.uiColor
        
        // Border
        borderStyle = .none
        
        // Placeholder
        placeholderColor = Palette.secondaryLight.uiColor
        
        // Input
        textColor = Palette.primary.uiColor
        
        // Tint
        tintColor = Palette.tint.uiColor
        
        // Input Line
        inputLine.backgroundColor = Palette.seperator.uiColor.cgColor
    }
    
    private func styleFocused() {
        styleNormal()
        
        // Input Line
        inputLine.backgroundColor = Palette.tint.uiColor.cgColor
    }
    
    private func styleError() {
        // Floating Label
        floatingLabelTextColor = Palette.secondaryLight.uiColor
        floatingLabelActiveTextColor = Palette.error.uiColor
        
        // Tint
        tintColor = Palette.error.uiColor
        
        // Input Line
        inputLine.backgroundColor = Palette.error.uiColor.cgColor
    }
}
