
// MARK: Task

protocol Task {
    var title: String { get }
    var subtitle: String? { get }
    var isCompleted: Bool { get }
    var prerequisites: [Int] { get }
    var detail: String? { get set }
}

// MARK: Basic Task

// MARK: Log Task

// MARK: Time Task

// MARK: Assessment Task
