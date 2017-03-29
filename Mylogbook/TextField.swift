
import UIKit
import JVFloatLabeledTextField

// MARK: Text Field Style

enum TextFieldStyle {
    case normal, focused ,error
}

// MARK: Text Field

class TextField: JVFloatLabeledTextField {
    
    private let inputLine = CALayer()
    
    private let errorLabel = UILabel()
    
    private let errorLabelYPadding: CGFloat = 6
    
    private let baseHeight: CGFloat = 40
    
    private var heightConstraint: NSLayoutConstraint!
    
    private var isDirty = false
    
    var error: String? {
        get {
            return errorLabel.text
        }
        
        set(message) {
            errorLabel.text = message
            
            updateHeight()
            
            updateStyle()
        }
    }
    
    var isValid: Bool {
        return error == nil
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
        borderStyle = .none
        
        setupConstraints()
        
        addInputLine()
        
        addErrorLabel()
        
        restyle(.normal)
        
        delegate = self
        
        addTarget(self, action: #selector(editingChangedHandler), for: .editingChanged)
    }
    
    private func setupConstraints() {
        heightConstraint = heightAnchor.constraint(equalToConstant: baseHeight)
        heightConstraint.isActive = true
    }
    
    private func addInputLine() {
        inputLine.backgroundColor = Palette.separator.uiColor.cgColor
        
        inputLine.frame = CGRect(x: 0, y: baseHeight - 1, width: bounds.width, height: 1)
        
        layer.addSublayer(inputLine)
    }
    
    private func addErrorLabel() {
        errorLabel.textColor = Palette.error.uiColor
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.frame = CGRect(x: 0,
                                  y: baseHeight + errorLabelYPadding,
                                  width: bounds.width,
                                  height: 14)
        
        addSubview(errorLabel)
    }
    
    @objc private func editingChangedHandler() {
        if !isDirty { isDirty = true }
    }
    
    // MARK: Layout
        
    private func updateHeight() {
        if !isValid { errorLabel.sizeToFit() }
        
        let height = isValid ? baseHeight : (baseHeight + errorLabelYPadding + errorLabel.frame.size.height)
        
        self.heightConstraint.constant = height
        
        layoutIfNeeded()
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        
        guard !isValid else { return rect }
        
        return rect.offsetBy(dx: 0, dy: -11)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        
        guard !isValid else { return rect }
        
        return rect.offsetBy(dx: 0, dy: -11)
    }
    
    // MARK: Responders
    
    override func becomeFirstResponder() -> Bool {
        if isValid || (!isDirty && isValid) { styleFocused() }
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if isValid || (!isDirty && isValid) { styleNormal() }
        
        return super.resignFirstResponder()
    }
    
    // MARK: Styling
    
    private func updateStyle() {
        if (!isValid) {
            restyle(.error)
        } else if isFirstResponder {
            restyle(.focused)
        } else {
            restyle(.normal)
        }
    }
    
    func restyle(_ style: TextFieldStyle) {
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
        floatingLabelTextColor = Palette.placeholder.uiColor
        floatingLabelActiveTextColor = Palette.tint.uiColor
        
        tintColor = Palette.tint.uiColor
        
        inputLine.backgroundColor = Palette.separator.uiColor.cgColor
    }
    
    private func styleFocused() {
        styleNormal()
        
        inputLine.backgroundColor = Palette.tint.uiColor.cgColor
    }
    
    private func styleError() {
        floatingLabelTextColor = Palette.placeholder.uiColor
        floatingLabelActiveTextColor = Palette.error.uiColor
        
        tintColor = Palette.error.uiColor
        
        inputLine.backgroundColor = Palette.error.uiColor.cgColor
    }
}

// MARK: Text Field Delegate

extension TextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = superview?.viewWithTag(tag + 1) as? TextField {
            _ = nextTextField.becomeFirstResponder()
        } else {
            _ = resignFirstResponder()
        }
        
        return false
    }
}
