
import UIKit

// MARK: Task

protocol Task: class {
    var title: NSMutableAttributedString { get }
    var subtitle: String? { get }
    var isComplete: Bool { get }
    var isCheckBoxEnabled: Bool { get }
    var completionHandler: ((Bool) -> Void)? { get set }
}

extension Task {
    var baseAttributes: [String: Any] {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular)]
    }
    
    var numericAttributes: [String: Any] {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)]
    }
}

// MARK: Basic Task

class BasicTask: Task {
    var title: NSMutableAttributedString {
        return NSMutableAttributedString(string: titleText)
    }

    var subtitle: String? = nil
    
    var isComplete: Bool
    
    var isCheckBoxEnabled = true
    
    var completionHandler: ((Bool) -> Void)? = nil
    
    var titleText: String
    
    init(title: String, isComplete: Bool) {
        self.titleText = title
        
        self.isComplete = isComplete
    }
}

// MARK: Log Task

class LogTask: Task  {
    var title: NSMutableAttributedString {
        let time = max(self.time, self.completionTime)
        
        let s1 = NSMutableAttributedString(string: "\(time)", attributes: numericAttributes)
        
        let s2 = NSMutableAttributedString(string: " out of ", attributes: baseAttributes)
        
        let s3 = NSMutableAttributedString(string: "\(self.completionTime)", attributes: numericAttributes)
        
        let s4 = NSMutableAttributedString(string: " hours logged", attributes: baseAttributes)
        
        s1.append(s2)
        
        s1.append(s3)
        
        s1.append(s4)
        
        return s1
    }
    
    var subtitle: String? = nil

    var isComplete: Bool {
        return time >= completionTime
    }
    
    var isCheckBoxEnabled = false
    
    var completionHandler: ((Bool) -> Void)? = nil

    var time: Int
    
    var completionTime: Int
    
    init(time: Int, completionTime: Int) {
        self.time = time
        
        self.completionTime = completionTime
    }
}

// MARK: Hold Task

class HoldTask: Task  {
    var title: NSMutableAttributedString {
        let days = self.days > 0 ? "\(self.days)" : ""
        
        let months = max(self.months, self.monthsRequired)
        
        let s1 = NSMutableAttributedString(string: "License held for ", attributes: baseAttributes)
        
        let s2 = NSMutableAttributedString(string: "\(months)", attributes: numericAttributes)
        
        let s3 = NSMutableAttributedString(string: " months and ", attributes: baseAttributes)
        
        let s4 = NSMutableAttributedString(string: "\(days)", attributes: numericAttributes)
        
        let s5 = NSMutableAttributedString(string: " days out of ", attributes: baseAttributes)
        
        let s6 = NSMutableAttributedString(string: "\(monthsRequired)", attributes: numericAttributes)
        
        let s7 = NSMutableAttributedString(string: " months", attributes: baseAttributes)
        
        s1.append(s2)
        s1.append(s3)
        s1.append(s4)
        s1.append(s5)
        s1.append(s6)
        s1.append(s7)
        
        return s1
    }

    var subtitle: String? = nil
    
    var isComplete: Bool {
        return months >= monthsRequired
    }
    
    var isCheckBoxEnabled = false
    
    var completionHandler: ((Bool) -> Void)? = nil
    
    var days: Int {
        return Date().days(since: startedAt)
    }
    
    var months: Int {
        return Date().months(since: startedAt)
    }
    
    var startedAt: Date
    
    var monthsRequired: Int
    
    init(startedAt: Date, monthsRequired: Int) {
        self.startedAt = startedAt
        
        self.monthsRequired = monthsRequired
    }
}

// MARK: Assessment Task

class AssessmentTask: Task {
    var title: NSMutableAttributedString {
        return NSMutableAttributedString(string: titleText)
    }

    var subtitle: String? {
        guard isComplete else { return nil }
        
        let completedAt = (self.completedAt ?? Date())
        
        return completedAt.string(format: .date)
    }
    
    var isComplete: Bool
    
    var isCheckBoxEnabled = true
    
    var completionHandler: ((Bool) -> Void)? = nil
    
    var titleText: String

    var completedAt: Date?
    
    init(title: String, isComplete: Bool, completedAt: Date?) {
        self.titleText = title
        
        self.isComplete = isComplete
        
        self.completedAt = completedAt
    }
}

