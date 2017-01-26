
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
    
    private var textField = [JVTextField: TextField]()
    
    private var validity = [JVTextField: Bool]()
    
    private var validations = [JVTextField: [Validation]]()
    
    func add(_ textField: TextField, _ validations: [Validation]) {
        let field = textField.field!
        
        self.textField[field] = textField
        
        self.validity[field] = false
        
        self.validations[field] = validations
        
        field.addTarget(self, action: #selector(editingChangedHandler(_:)), for: .editingChanged)
    }
    
    func setActionButton(_ button: UIBarButtonItem) {
        actionButton = button
        
        button.isEnabled = false
    }
    
    // MARK: Validation

    private func validate(_ field: JVTextField) -> Validation? {
        let value = field.text ?? ""
        
        for validation in validations[field]! { if !validation.validate(value) { return validation } }
        
        return nil
    }
    
    func revalidate() {
        for (field, textField) in textField {
            let isValid = (validate(field) == nil)
            
            validity[field] = isValid
            
            if isValid {
                delegate?.validationSuccessful(textField)
            } else {
                delegate?.validationFailed(textField)
            }
        }
        
        if isAllFieldsValid() { actionButton?.isEnabled = true }
    }
        
    private func isAllFieldsValid() -> Bool {
        return !(validity.values.contains(false))
    }
    
    private func validHandler(_ textField: TextField) {
        textField.error = nil

        validity[textField.field] = true
        
        if isAllFieldsValid() { actionButton?.isEnabled = true }
        
        delegate?.validationSuccessful(textField)
    }
    
    private func invalidHandler(_ textField: TextField, _ error: String?) {
        textField.error = error
        
        validity[textField.field] = false
        
        actionButton?.isEnabled = false
        
        delegate?.validationFailed(textField)
    }
    
    // MARK: Target Handlers

    @objc func editingChangedHandler(_ field: JVTextField) {
        let textField = self.textField[field]!
        
        if let failedValidation = validate(field) {
            invalidHandler(textField, failedValidation.error)
            
            return
        }
        
        validHandler(textField)
    }
}
