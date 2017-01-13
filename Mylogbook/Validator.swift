
import UIKit

// MARK: Field Attributes

struct FieldAttributes {
    let validations: [Validation]
    let errorLabel: UILabel
    
    init(_ errorLabel: UILabel, _ validations: [Validation]) {
        self.errorLabel = errorLabel
        self.validations = validations
    }
}

// MARK: Validator Delegate

protocol ValidatorDelegate {
    func validationSuccessful(_ textField: TextField)
    func validationFailed(_ textField: TextField)
}

// MARK: Validator

class Validator {
    var delegate: ValidatorDelegate?
    
    private var actionButton: UIBarButtonItem?
    
    private var fields = [TextField: FieldAttributes]()
    
    func addField(_ field: TextField, _ errorLabel: UILabel, _ validations: [Validation]) {
        fields[field] = FieldAttributes(errorLabel, validations)
        
        errorLabel.isHidden = true
        
        field.addTarget(self, action: #selector(editingChangedHandler(_:)), for: .editingChanged)
    }
    
    func setActionButton(_ button: UIBarButtonItem) {
        actionButton = button
        
        button.isEnabled = false
    }
    
    // MARK: Validation
    
    func forceValidateAllFields() {
        for field in fields.keys { editingChangedHandler(field) }
    }
    
    private func validateField(_ value: String, _ validations: [Validation]) -> Validation? {
        for validation in validations { if !validation.validate(value) { return validation } }
        
        return nil
    }
    
    private func isAllFieldsValid() -> Bool {
        return !(fields.keys.map({ $0.isValid }).contains(false))
    }
    
    private func setErrorMessage(_ field: TextField, error: String?) {
        let errorLabel = fields[field]!.errorLabel
        
        errorLabel.isHidden = (error == nil)
        errorLabel.text = error
    }
    
    private func validHandler(_ field: TextField) {
        field.isValid = true
        
        setErrorMessage(field, error: nil)
        
        if isAllFieldsValid() { actionButton?.isEnabled = true }
        
        delegate?.validationSuccessful(field)
    }
    
    private func invalidHandler(_ field: TextField, _ failedValidation: Validation) {
        field.isValid = false
        
        setErrorMessage(field, error: failedValidation.error)
        
        actionButton?.isEnabled = false
        
        delegate?.validationFailed(field)
    }
    
    // MARK: Target Handlers

    @objc func editingChangedHandler(_ field: TextField) {
        let text = field.text ?? ""
        
        let validations = fields[field]!.validations
        
        if let failedValidation = validateField(text, validations) {
            invalidHandler(field, failedValidation)
            
            return
        }
        
        validHandler(field)
    }
}
