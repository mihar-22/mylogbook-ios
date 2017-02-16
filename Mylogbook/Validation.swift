
import Foundation

// MARK: Validation

enum Validation {
    case required
    case minLength(min: Int)
    case maxLength(max: Int)
    case regex(pattern: String, message: String)
    case email
    case alpha
    case alphaSpace
    case alphaNum
    case alphaNumSpace
    case numeric
    
    // MARK: Error
    
    var error: String {
        switch self {
        case .required:
            return "This field is required"
        case .minLength(let min):
            return "Must be at least \(min) characters"
        case .maxLength(let max):
            return "Must be no more than \(max) characters"
        case .regex(_, let message):
            return message
        case .email:
            return "Must be a valid e-mail address"
        case .alpha:
            return "Only letters (a-z)"
        case .alphaSpace:
            return "Only letters (a-z) and spaces are allowed"
        case .alphaNum:
            return "Only letters (a-z) and numbers (0-9) are allowed"
        case .alphaNumSpace:
            return "Only letters (a-z), numbers (0-9) and spaces are allowed"
        case .numeric:
            return "Only numbers (0-9)"
        }
    }
    
    // MARK: Validate
    
    func validate(_ value: String) -> Bool {
        switch self {
        case .required:
            return !value.isEmpty
        case .minLength(let min):
            return value.characters.count >= min
        case .maxLength(let max):
            return value.characters.count <= max
        case .regex(let pattern, _):
            return regexTest(value, pattern)
        case .email:
            return regexTest(value, "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
        case .alpha:
            return regexTest(value, "^[A-Za-z]+$")
        case .alphaSpace:
            return regexTest(value, "^[A-Za-z\\s]+$")
        case .alphaNum:
            return regexTest(value, "^[A-Za-z0-9]+$")
        case .alphaNumSpace:
            return regexTest(value, "^[A-Za-z0-9\\s]+$")
        case .numeric:
            return regexTest(value, "^[\\,0-9]+$")
        }
    }
    
    // MARK: Regex Test
    
    private func regexTest(_ value: String, _ regex: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return test.evaluate(with: value)
    }
}
