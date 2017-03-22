
import Foundation

// MARK: Australian State

enum AustralianState: String {
    case newSouthWhales = "New South Whales"
    case queensland = "Queensland"
    case southAustralia = "South Australia"
    case tasmania = "Tasmania"
    case victoria = "Victoria"
    case westernAustralia = "Western Australia"
    
    static let all = [
        newSouthWhales,
        queensland,
        southAustralia,
        tasmania,
        victoria,
        westernAustralia
    ]
    
    var abbreviated: String {
        switch self {
        case .victoria:
            return "vic"
        case .newSouthWhales:
            return "nsw"
        case .queensland:
            return "qld"
        case .southAustralia:
            return "sa"
        case .tasmania:
            return "tas"
        case .westernAustralia:
            return "wa"
        }
    }
    
    var isBonusCreditsAvailable: Bool {
        return self == .newSouthWhales || self == .queensland
    }
    
    var isTestsAvailable: Bool {
        return self == .tasmania || self == .westernAustralia
    }
    
    func `is`(_ state: AustralianState) -> Bool {
        return self == state
    }
}

// MARK: Requirements

extension AustralianState {
    var totalLoggedTimeRequired: Int {
        let (day, night) = loggedTimeRequired
        
        guard self != .tasmania && self != .westernAustralia else {
            return day
        }
        
        return (day + night)
    }
    
    var loggedTimeRequired: (day: Int, night: Int) {
        switch self {
        case .victoria:
            return (396_000, 36_000)
        case .newSouthWhales:
            return (360_000, 72_000)
        case .queensland:
            return (324_000, 36_000)
        case .southAustralia:
            return (216_000, 54_000)
        case .tasmania:
            return (288_000, 288_000)
        case .westernAustralia:
            return (180_000, 180_000)
        }
    }
    
    var monthsRequired: Int {
        let birthday = Keychain.shared.get(.birthday)!.utc(format: .date)
        
        let age = Date().years(since: birthday)
        
        switch self {
        case .victoria:
            if age < 21 {
                return 12
            } else if age >= 21 && age <= 25 {
                return 6
            } else {
                return 3
            }
        case .newSouthWhales:
            return 12
        case .queensland:
            return 12
        case .southAustralia:
            if age < 25 {
                return 12
            } else {
                return 6
            }
        case .tasmania:
            return 12
        case .westernAustralia:
            return 6
        }
    }
}

// MARK: Bonus

extension AustralianState {
    var totalBonusAvailable: Int {
        switch self {
        case .queensland, .newSouthWhales:
            return 72_000
        default:
            return 0
        }
    }
        
    var bonusMultiplier: Int {
        switch self {
        case .queensland, .newSouthWhales:
            return 3
        default:
            return 0
        }
    }
    
    static var timeRequiredForSaferDrivers: Int {
        return 180_000
    }
    
    static var saferDriversBonus: Int {        
        return 72_000
    }
}

// MARK: Stages

extension AustralianState {
    enum TasmaniaStage { case L1, L2 }
    
    enum WesternAustraliaStage { case S1, S2 }
    
    static func loggedTimeRequired(for stage: TasmaniaStage) -> Int {
        switch stage {
        case .L1:
            return 108_000
        case .L2:
            return 180_000
        }
    }
    
    static func loggedTimeRequired(for stage: WesternAustraliaStage) -> Int {
        switch stage {
        case .S1:
            return 90_000
        case .S2:
            return 90_000
        }
    }
    
    static func monthsRequired(for stage: TasmaniaStage) -> Int {
        switch stage {
        case .L1:
            return 3
        case .L2:
            return 9
        }
    }
    
    static func monthsRequired(for stage: WesternAustraliaStage) -> Int {
        switch stage {
        case .S1:
            return 0
        case .S2:
            return 6
        }
    }
}
