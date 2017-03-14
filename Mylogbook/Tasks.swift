
import Foundation

// MARK: Tasks

class Tasks {
    private var tasks = [Task]()
    
    private var statistics: Statistics {
        return Cache.shared.statistics
    }
    
    private var residingState: AustralianState {
        return Cache.shared.residingState
    }
    
    private var entries: Entries {
        return Cache.shared.currentEntries
    }
    
    var count: Int {
        return tasks.count
    }
    
    // MARK: Subscript
    
    subscript(index: Int) -> Task {
        return tasks[index]
    }
    
    // MARK: Build
    
    func build() {
        tasks.removeAll()
        
        switch Cache.shared.residingState {
        case .victoria:
            buildTasksForVictoria()
        case .newSouthWhales:
            buildTasksForNewSouthWhales()
        case .queensland:
            buildTasksForQueensland()
        case .southAustralia:
            buildTasksForSouthAustralia()
        case .tasmania:
            buildTasksForTasmania()
        case .westernAustralia:
            buildTasksForWesternAustralia()
        }
    }
    
    private func buildTasksForVictoria() {
        addLogTask()
        
        addHoldTask()
        
        addHazardPerceptionTestTask()
    
        addDrivingTestTask(title: "Driving Test", with: [tasks[2]])
    }
    
    private func buildTasksForNewSouthWhales() {
        addLogTask()
        
        addHoldTask()

        addBonusTask()
        
        let logFiftyHours = LogTask(time: statistics.totalLogged,
                                    completionTime: AustralianState.timeRequiredForSaferDrivers,
                                    dependencies: [])
        
        var saferDrivers = BasicTask(title: "Safer Drivers Course",
                                     isComplete: (entries.isSaferDriversComplete ?? false),
                                     dependencies: [logFiftyHours])
        
        saferDrivers.subtitle = saferDrivers.isActive ? "Earned 20 hours of bonus credits" : "Requires 50 hours logged"
        
        saferDrivers.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isSaferDriversComplete = isChecked
        }
        
        tasks.append(saferDrivers)
        
        addDrivingTestTask()
    }
    
    private func buildTasksForQueensland() {
        addLogTask()
        
        addHoldTask()
        
        addBonusTask()
        
        addDrivingTestTask()
    }
    
    private func buildTasksForSouthAustralia() {
        addLogTask()
        
        addHoldTask()
        
        addHazardPerceptionTestTask()
        
        addDrivingTestTask(title: "Vehicle On Road Test", with: [tasks[2]])
        
        addDrivingTestTask(title: "Competency Based Training Course", with: [tasks[2]])
    }

    private func buildTasksForTasmania() {
        let l1LogTask = LogTask(time: statistics.totalLogged,
                                completionTime: AustralianState.loggedTimeRequired(for: .L1),
                                dependencies: [])
        
        tasks.append(l1LogTask)
        
        let l1HoldTask = HoldTask(startedAt: Keychain.shared.get(.permitReceivedAt)!.date(format: .date),
                                  monthsRequired: AustralianState.monthsRequired(for: .L1),
                                  dependencies: [])
        
        tasks.append(l1HoldTask)
        
        addAssessmentTask(title: "L2 Driving Assessment", with: [l1LogTask, l1HoldTask])
        
        let l2LogTask = LogTask(time: max(0, statistics.totalLogged - AustralianState.loggedTimeRequired(for: .L1)),
                                completionTime: AustralianState.loggedTimeRequired(for: .L2),
                                dependencies: [tasks[2]])
        
        tasks.append(l2LogTask)
        
        let l2HoldTask = HoldTask(startedAt: (entries.assessmentCompletedAt ?? Date()),
                                  monthsRequired: AustralianState.monthsRequired(for: .L2),
                                  dependencies: [tasks[2]])
        
        tasks.append(l2HoldTask)
        
        addDrivingTestTask(title: "P1 Driving Assessment", with: [l2LogTask, l2HoldTask])
    }
    
    private func buildTasksForWesternAustralia() {
        let s1LogTask = LogTask(time: statistics.totalLogged,
                                completionTime: AustralianState.loggedTimeRequired(for: .S1),
                                dependencies: [])
        
        tasks.append(s1LogTask)
        
        addAssessmentTask(title: "Practical Driving Assessment", with: [s1LogTask])
        
        let s2LogTask = LogTask(time: max(0, (statistics.totalLogged - AustralianState.loggedTimeRequired(for: .S1))),
                                completionTime: AustralianState.loggedTimeRequired(for: .S2),
                                dependencies: [tasks[1]])
        
        tasks.append(s2LogTask)
        
        let s2HoldTask = HoldTask(startedAt: (entries.assessmentCompletedAt ?? Date()),
                                  monthsRequired: AustralianState.monthsRequired(for: .S2),
                                  dependencies: [tasks[1]])
        
        tasks.append(s2HoldTask)
        
        addHazardPerceptionTestTask(with: [s2LogTask, s2HoldTask])
    }
    
    // MARK: Default Tasks
    
    private func addLogTask() {
        let logHours = LogTask(time: statistics.totalLogged,
                               completionTime: residingState.totalLoggedTimeRequired,
                               dependencies: [])
        
        tasks.append(logHours)
    }
    
    private func addHoldTask() {
        let holdLicense = HoldTask(startedAt: Keychain.shared.get(.permitReceivedAt)!.date(format: .date),
                                   monthsRequired: residingState.monthsRequired,
                                   dependencies: [])
        
        tasks.append(holdLicense)
    }
    
    private func addBonusTask() {
        var bonusCredits = LogTask(time: statistics.totalBonusEarned,
                                   completionTime: residingState.totalBonusAvailable,
                                   dependencies: [])
        
        bonusCredits.isBonus = true
        
        tasks.append(bonusCredits)
    }
    
    private func addHazardPerceptionTestTask(with dependencies: [Task] = []) {
        let dependencies = (dependencies.count > 0) ? dependencies : [tasks[0], tasks[1]]
        
        var perceptionTest = BasicTask(title: "Hazard Perception Test",
                                       isComplete: entries.isHazardsComplete,
                                       dependencies: dependencies)
        
        perceptionTest.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isHazardsComplete = isChecked
        }
        
        tasks.append(perceptionTest)
    }
    
    private func addAssessmentTask(title: String, with dependencies: [Task]) {
        var assessment = AssessmentTask(title: title,
                                        isComplete: (entries.isAssessmentComplete ?? false),
                                        completedAt: entries.assessmentCompletedAt,
                                        dependencies: dependencies)
        
        assessment.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isAssessmentComplete = isChecked
            
            Cache.shared.currentEntries.assessmentCompletedAt = Date()
        }
        
        assessment.editCompletionHandler = { date in
            Cache.shared.currentEntries.assessmentCompletedAt = date
        }
        
        tasks.append(assessment)
    }
    
    private func addDrivingTestTask(title: String = "Driving Test", with dependencies: [Task] = []) {
        var drivingTest = BasicTask(title: title,
                                    isComplete: entries.isDrivingTestComplete,
                                    dependencies: ([tasks[0], tasks[1]] + dependencies))
        
        drivingTest.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isDrivingTestComplete = isChecked
        }
        
        tasks.append(drivingTest)
    }
}
