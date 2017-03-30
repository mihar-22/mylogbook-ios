
import UIKit

// MARK: Validator Delegate

protocol ValidatorDelegate {
    func validationSuccessful(_ textField: TextField)
    
    func validationFailed(_ textField: TextField)
}

// MARK: Validator

class Validator {
    var delegate: ValidatorDelegate?
    
    private var actionButton: UIBarButtonItem?
    
    private var validations = [TextField: [Validation]]()
    
    func add(_ textField: TextField, _ validations: [Validation]) {
        self.validations[textField] = validations
        
        textField.error = validate(textField)?.error
        
        textField.addTarget(self, action: #selector(editingChangedHandler(_:)), for: .editingChanged)
    }
    
    func setActionButton(_ button: UIBarButtonItem) {
        actionButton = button
        
        button.isEnabled = false
    }
    
    // MARK: Validation

    private func validate(_ field: TextField) -> Validation? {
        let value = field.text ?? ""
        
        for validation in validations[field]! { if !validation.validate(value) { return validation } }
        
        return nil
    }
    
    func revalidate() {
        for textField in validations.keys {
            textField.error = validate(textField)?.error
            
            if textField.isValid {
                delegate?.validationSuccessful(textField)
            } else {
                delegate?.validationFailed(textField)
            }
        }
        
        if isAllFieldsValid() { actionButton?.isEnabled = true }
    }
        
    private func isAllFieldsValid() -> Bool {
        return !(validations.map({ $0.key.isValid }).contains(false))
    }
    
    private func validHandler(_ textField: TextField) {
        textField.error = nil
        
        if isAllFieldsValid() { actionButton?.isEnabled = true }
        
        delegate?.validationSuccessful(textField)
    }
    
    private func invalidHandler(_ textField: TextField, _ error: String) {
        textField.error = error
        
        actionButton?.isEnabled = false
        
        delegate?.validationFailed(textField)
    }
    
    // MARK: Target Handlers

    @objc func editingChangedHandler(_ field: TextField) {
        if let failedValidation = validate(field) {
            invalidHandler(field, failedValidation.error)
            
            return
        }
        
        validHandler(field)
    }
}
