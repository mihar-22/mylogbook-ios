
import Foundation
import UIKit

// MARK: Value Formatter

class ValueFormatter {
    
    private let formatter = NumberFormatter()
    
    init() {
        formatter.numberStyle = .decimal
        
        formatter.maximumFractionDigits = 0
    }
    
    func number(from string: String?) -> NSNumber? {
        guard (string != nil) && !string!.isEmpty else { return nil }
        
        guard Validation.numeric.validate(string!) else { return nil }
        
        return formatter.number(from: unformatted(string: string!))
    }
    
    func string(from number: NSNumber) -> String {
        return formatter.string(from: number)!
    }
    
    func reformat(string: String?) -> String? {
        guard let number = self.number(from: string) else { return nil }
        
        return self.string(from: number)
    }
        
    func unformatted(string: String) -> String {
        return string.replacingOccurrences(of: ",", with: "")
    }
}

// MARK: UI Text Field

extension UITextField {
    var formatter: ValueFormatter {
       return ValueFormatter()
    }
    
    var value: Int {
        return (formatter.number(from: valueText) as? Int) ?? 0
    }
    
    var valueText: String? {
        get {
            guard text != nil && !text!.isEmpty else { return nil }
            
            return formatter.unformatted(string: text!)
        }
        
        set(valueText) {
            guard valueText != nil && !valueText!.isEmpty else { return }
            
            text = formatter.reformat(string: valueText)
        }
    }
    
    func setupValueFormatting() {
        addTarget(self,
                  action: #selector(_editingChangedHandler(_:)),
                  for: .editingChanged)
    }
    
    // MARK: Handlers
    
    @objc func _editingChangedHandler(_ sender: UITextField) {
        valueText = sender.text
    }
}
