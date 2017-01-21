
import UIKit

// MARK: Field Attributes

struct FieldAttributes {
    let validations: [Validation]
    let errorLabel: UILabel
    var validity = false
    
    init(_ errorLabel: UILabel, _ validations: [Validation]) {
        self.errorLabel = errorLabel
        self.validations = validations
    }
    
    mutating func setValidity(_ validity: Bool) {
        self.validity = validity
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
    
    private var isUpdatingUI = true
    
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
    
    func revalidate(updateUI: Bool) {
        isUpdatingUI = updateUI
        
        for field in fields.keys { editingChangedHandler(field) }
        
        if !isUpdatingUI { isUpdatingUI = true }
    }
    
    private func validateField(_ value: String, _ validations: [Validation]) -> Validation? {
        for validation in validations { if !validation.validate(value) { return validation } }
        
        return nil
    }
    
    private func isAllFieldsValid() -> Bool {
        return !(fields.values.map({ $0.validity }).contains(false))
    }
    
    private func validHandler(_ field: TextField) {
        fields[field]!.setValidity(true)
        
        updateUI(field, isValid: true, error: nil)
        
        if isAllFieldsValid() { actionButton?.isEnabled = true }
        
        delegate?.validationSuccessful(field)
    }
    
    private func invalidHandler(_ field: TextField, _ error: String?) {
        fields[field]!.setValidity(false)
        
        updateUI(field, isValid: false, error: error)
        
        actionButton?.isEnabled = false
        
        delegate?.validationFailed(field)
    }
    
    private func updateUI(_ field: TextField, isValid: Bool, error: String?) {
        guard isUpdatingUI else { return }
        
        field.isValid = isValid
        
        setErrorMessage(field, error: error)
    }
    
    private func setErrorMessage(_ field: TextField, error: String?) {
        let errorLabel = fields[field]!.errorLabel
        
        errorLabel.isHidden = (error == nil)
        errorLabel.text = error
    }
    
    // MARK: Target Handlers

    @objc func editingChangedHandler(_ field: TextField) {
        let text = field.text ?? ""
        
        let validations = fields[field]!.validations
        
        if let failedValidation = validateField(text, validations) {
            invalidHandler(field, failedValidation.error)
            
            return
        }
        
        validHandler(field)
    }
}
