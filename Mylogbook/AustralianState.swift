
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
    
    // MARK: Checks
    
    var isBonusCreditsAvailable: Bool {
        return self == .newSouthWhales || self == .queensland
    }
    
    var isTestsAvailable: Bool {
        return self == .tasmania || self == .westernAustralia
    }
    
    func `is`(_ state: AustralianState) -> Bool {
        return self == state
    }
    
    // MARK: Requirements
    
    var loggedTimeRequired: (Int, Int) {
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
        switch self {
        case .victoria:
            return 0
        case .newSouthWhales:
            return 0
        case .queensland:
            return 0
        case .southAustralia:
            return 0
        case .tasmania:
            return 0
        case .westernAustralia:
            return 0
        }
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
