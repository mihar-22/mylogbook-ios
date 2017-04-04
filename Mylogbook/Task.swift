
import UIKit

// MARK: Task

protocol Task {
    var title: NSMutableAttributedString { get }
    var subtitle: String? { get }
    var learnMoreURL: URL? { get set }
    
    var checkBoxHandler: ((Bool) -> Void)? { get set }
    var editCompletionHandler: ((Date) -> Void)? { get set }

    var isComplete: Bool { get }
    var isActive: Bool { get }
    var dependencies: [Task] { get }
}

extension Task {
    var isActive: Bool {
        guard dependencies.count > 0 else { return true }
        
        return dependencies.filter({ !$0.isComplete }).count == 0
    }
    
    var baseAttributes: [String: Any] {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)]
    }
    
    var numericAttributes: [String: Any] {
        return [NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)]
    }
}

// MARK: Basic Task

struct BasicTask: Task {
    var title: NSMutableAttributedString {
        return NSMutableAttributedString(string: titleText, attributes: baseAttributes)
    }

    var subtitle: String? = nil

    var learnMoreURL: URL? = nil
    
    var isComplete: Bool
    
    var checkBoxHandler: ((Bool) -> Void)? = nil
    
    var editCompletionHandler: ((Date) -> Void)? = nil
    
    var dependencies: [Task]
    
    var titleText: String
    
    init(title: String, isComplete: Bool, dependencies: [Task]) {
        self.titleText = title
        
        self.isComplete = isComplete
        
        self.dependencies = dependencies
    }
}

// MARK: Log Task

struct LogTask: Task  {
    var title: NSMutableAttributedString {
        let time = min(self.time, self.completionTime)
        
        let s1Text = isBonus ? "Earned " : "Total of "
        
        let s1 = NSMutableAttributedString(string: s1Text, attributes: baseAttributes)

        let s2 = NSMutableAttributedString(string: "\(time) / \(completionTime)", attributes: numericAttributes)
        
        let s3Text = isBonus ? " bonus hours" : " hours logged"
        
        let s3 = NSMutableAttributedString(string: s3Text, attributes: baseAttributes)
        
        s1.append(s2)

        s1.append(s3)

        return s1
    }
    
    var subtitle: String? = nil

    var learnMoreURL: URL? = nil
    
    var isBonus: Bool = false
    
    var isComplete: Bool { return time >= completionTime }
    
    var checkBoxHandler: ((Bool) -> Void)? = nil

    var editCompletionHandler: ((Date) -> Void)? = nil
    
    var dependencies: [Task]

    var time: Int
    
    var completionTime: Int
    
    init(time: Int, completionTime: Int, dependencies: [Task]) {
        self.time = time.convert(from: .second, to: .hour)
        
        self.completionTime = completionTime.convert(from: .second, to: .hour)
        
        self.dependencies = dependencies
    }
}

// MARK: Hold Task

struct HoldTask: Task  {
    var title: NSMutableAttributedString {
        let months = min(self.months, self.monthsRequired)
        
        let s1 = NSMutableAttributedString(string: "License held for ", attributes: baseAttributes)
        
        let s2 = NSMutableAttributedString(string: "\(months) / \(monthsRequired)", attributes: numericAttributes)
        
        let s3 = NSMutableAttributedString(string: " months", attributes: baseAttributes)
        
        s1.append(s2)
        s1.append(s3)
        
        return s1
    }

    var subtitle: String? = nil
    
    var learnMoreURL: URL? = nil
    
    var isComplete: Bool {
        return months >= monthsRequired
    }
    
    var checkBoxHandler: ((Bool) -> Void)? = nil
    
    var editCompletionHandler: ((Date) -> Void)? = nil
    
    var dependencies: [Task]
    
    var months: Int {
        return Date().months(since: startedAt)
    }
    
    var startedAt: Date
    
    var monthsRequired: Int
    
    init(startedAt: Date, monthsRequired: Int, dependencies: [Task]) {
        self.startedAt = startedAt
        
        self.monthsRequired = monthsRequired
        
        self.dependencies = dependencies
    }
}

// MARK: Assessment Task

struct AssessmentTask: Task {
    var title: NSMutableAttributedString {
        return NSMutableAttributedString(string: titleText, attributes: baseAttributes)
    }

    var subtitle: String? {
        guard isComplete else { return nil }
        
        let completedAt = (self.completedAt ?? Date())
        
        return completedAt.local(date: .long, time: .none)
    }
    
    var learnMoreURL: URL? = nil
    
    var isComplete: Bool
    
    var checkBoxHandler: ((Bool) -> Void)? = nil
    
    var editCompletionHandler: ((Date) -> Void)? = nil
    
    var dependencies: [Task]
    
    var titleText: String

    var completedAt: Date?
    
    init(title: String, isComplete: Bool, completedAt: Date?, dependencies: [Task]) {
        self.titleText = title
        
        self.isComplete = isComplete
        
        self.completedAt = completedAt
        
        self.dependencies = dependencies
    }
}

