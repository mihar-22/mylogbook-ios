
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

    // MARK: Victoria Tasks

    private func buildTasksForVictoria() {
        // 1.
        let logTask = createLogTask()
        
        tasks.append(logTask)
        
        // 2.
        let holdTask = createHoldTask()
        
        tasks.append(holdTask)
        
        // 3. -> [1, 2]
        let learnMoreURL = "https://www.vicroads.vic.gov.au/licences/your-ps/get-your-ps/how-to-get-your-ps"

        var perceptionTest = createHazardPerceptionTest(with: [logTask, holdTask])
        
        perceptionTest.learnMoreURL = URL(string: learnMoreURL)
        
        tasks.append(perceptionTest)
        
        // 4. -> [3]
        var drivingTest = createDrivingTest(title: "Driving Test", with: [perceptionTest])
        
        drivingTest.learnMoreURL = URL(string: learnMoreURL)
        
        tasks.append(drivingTest)
    }

    // MARK: New South Whales Tasks

    private func buildTasksForNewSouthWhales() {
        // 1.
        let logTask = createLogTask()
        
        tasks.append(logTask)
        
        // 2.
        let holdTask = createHoldTask()
        
        tasks.append(holdTask)
        
        // 3.
        var bonusTask = createBonusTask()
        
        bonusTask.learnMoreURL = URL(string: "http://www.rms.nsw.gov.au/roads/licence/driver/learner#3_for_1")
        
        tasks.append(bonusTask)
        
        // 4.1
        let logFiftyHours = LogTask(time: statistics.totalLogged,
                                    completionTime: AustralianState.timeRequiredForSaferDrivers,
                                    dependencies: [])
        
        // 4.2 -> [4.1]
        var saferDrivers = BasicTask(title: "Safer Drivers Course",
                                     isComplete: (entries.isSaferDriversComplete ?? false),
                                     dependencies: [logFiftyHours])
        
        
        saferDrivers.learnMoreURL = URL(string: "http://www.rms.nsw.gov.au/cgi-bin/index.cgi?action=saferdriverscourseproviders.form")
        
        if saferDrivers.isComplete && saferDrivers.isActive {
            saferDrivers.subtitle = "Earned 20 bonus hours"
        } else {
            saferDrivers.subtitle = saferDrivers.isActive ? "Earn 20 bonus hours" :
                                                            "Requires 50 hours logged"
        }
        
        saferDrivers.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isSaferDriversComplete = isChecked
        }
        
        tasks.append(saferDrivers)
        
        // 5. -> [1, 2]
        var drivingTest = createDrivingTest(title: "Driving Test", with: [logTask, holdTask])
        
        drivingTest.learnMoreURL = URL(string: "http://www.rms.nsw.gov.au/roads/licence/driver/tests/driving-test.html")
        
        tasks.append(drivingTest)
    }

    // MARK: Queensland Tasks
    
    private func buildTasksForQueensland() {
        // 1.
        let logTask = createLogTask()
        
        tasks.append(logTask)

        // 2.
        let holdTask = createHoldTask()
        
        tasks.append(holdTask)
        
        // 3.
        var bonusTask = createBonusTask()
        
        bonusTask.learnMoreURL = URL(string: "https://www.qld.gov.au/transport/licensing/getting/learner-logbook/index.html#100hours")
        
        tasks.append(bonusTask)

        // 4. -> [1, 2]
        var drivingTest = createDrivingTest(title: "Practical Driving Test", with: [logTask, holdTask])
        
        drivingTest.learnMoreURL = URL(string: "https://www.qld.gov.au/transport/licensing/getting/tests/index.html#practical")
        
        tasks.append(drivingTest)
    }
    
    // MARK: South Australia Tasks
    
    private func buildTasksForSouthAustralia() {
        // 1.
        let logTask = createLogTask()
        
        tasks.append(logTask)
        
        // 2.
        let holdTask = createHoldTask()
        
        tasks.append(holdTask)
        
        // 3. -> [1, 2]
        var perceptionTest = createHazardPerceptionTest(with: [logTask, holdTask])
        
        perceptionTest.learnMoreURL = URL(string: "http://mylicence.sa.gov.au/the-hazard-perception-test")
        
        tasks.append(perceptionTest)
        
        // 4. -> [3]
        var onRoadTest = createDrivingTest(title: "Vehicle On Road Test", with: [perceptionTest])
        
        onRoadTest.learnMoreURL = URL(string : "http://www.mylicence.sa.gov.au/the-driving-companion/vort")
        
        tasks.append(onRoadTest)
        
        // 5. -> [3]
        var competencyCourse = createDrivingTest(title: "Competency Based Training", with: [perceptionTest])
        
        competencyCourse.learnMoreURL = URL(string: "http://www.mylicence.sa.gov.au/the-driving-companion/competency-based-training-assessment")
        
        tasks.append(competencyCourse)
    }

    // MARK: Tasmania Tasks
    
    private func buildTasksForTasmania() {
        // 1.
        var l1LogTask = LogTask(time: statistics.totalLogged,
                                completionTime: AustralianState.loggedTimeRequired(for: .L1),
                                dependencies: [])
        
        l1LogTask.subtitle = "L1"
        
        tasks.append(l1LogTask)
        
        // 2.
        var l1HoldTask = HoldTask(startedAt: Keychain.shared.get(.permitReceivedAt)!.date(format: .date),
                                  monthsRequired: AustralianState.monthsRequired(for: .L1),
                                  dependencies: [])
        
        l1HoldTask.subtitle = "L1"
        
        tasks.append(l1HoldTask)
        
        // 3. -> [1, 2]
        var l2AssessmentTask = createAssessmentTask(title: "L2 Driving Assessment", with: [l1LogTask, l1HoldTask])
        
        l2AssessmentTask.learnMoreURL = URL(string: "http://www.transport.tas.gov.au/novice/l1/car/book_your_l2_driving_assessment")
        
        tasks.append(l2AssessmentTask)
        
        // 4. -> [3]
        var l2LogTask = LogTask(time: max(0, statistics.totalLogged - AustralianState.loggedTimeRequired(for: .L1)),
                                completionTime: AustralianState.loggedTimeRequired(for: .L2),
                                dependencies: [l2AssessmentTask])
        
        l2LogTask.subtitle = "L2"
        
        tasks.append(l2LogTask)
        
        // 5. -> [3]
        var l2HoldTask = HoldTask(startedAt: (entries.assessmentCompletedAt ?? Date()),
                                  monthsRequired: AustralianState.monthsRequired(for: .L2),
                                  dependencies: [l2AssessmentTask])
        
        l2HoldTask.subtitle = "L2"
        
        tasks.append(l2HoldTask)
        
        // 6. -> [4, 5]
        var drivingTest = createDrivingTest(title: "P1 Driving Assessment", with: [l2LogTask, l2HoldTask])
        
        drivingTest.learnMoreURL = URL(string: "http://www.transport.tas.gov.au/novice/l2/car/book_your_p1_driving_assessment")
        
        tasks.append(drivingTest)
    }
    
    // MARK: Western Australia Tasks
    
    private func buildTasksForWesternAustralia() {
        // 1.
        var s1LogTask = LogTask(time: statistics.totalLogged,
                                completionTime: AustralianState.loggedTimeRequired(for: .S1),
                                dependencies: [])
        
        s1LogTask.subtitle = "Stage 1"
        
        tasks.append(s1LogTask)
        
        // 2. -> [1]
        var practicalAssessment = createAssessmentTask(title: "Practical Driving Assessment", with: [s1LogTask])
        
        practicalAssessment.learnMoreURL = URL(string: "http://www.transport.wa.gov.au/licensing/step-3-pass-practical-assessment.asp")
        
        tasks.append(practicalAssessment)

        // 3. -> [2]
        var s2LogTask = LogTask(time: max(0, (statistics.totalLogged - AustralianState.loggedTimeRequired(for: .S1))),
                                completionTime: AustralianState.loggedTimeRequired(for: .S2),
                                dependencies: [practicalAssessment])
        
        s2LogTask.subtitle = "Stage 2"
        
        tasks.append(s2LogTask)
        
        // 4. -> [2]
        var s2HoldTask = HoldTask(startedAt: (entries.assessmentCompletedAt ?? Date()),
                                  monthsRequired: AustralianState.monthsRequired(for: .S2),
                                  dependencies: [practicalAssessment])
        
        s2HoldTask.subtitle = "Stage 2"
        
        tasks.append(s2HoldTask)
        
        // 5. -> [3, 4]
        var perceptionTest = createHazardPerceptionTest(with: [s2LogTask, s2HoldTask])
        
        perceptionTest.learnMoreURL = URL(string: "http://www.transport.wa.gov.au/licensing/step-5-complete-hazard-perception-test.asp")
        
        tasks.append(perceptionTest)
        
        // 6. -> [5]
        var getLicense = createDrivingTest(title: "Get Provisional License", with: [perceptionTest])
        
        getLicense.learnMoreURL = URL(string: "http://www.transport.wa.gov.au/licensing/step-6-get-a-provisional-licence-p-plates.asp")
        
        tasks.append(getLicense)
    }
    
    // MARK: Default Tasks
    
    private func createLogTask() -> Task {
        return LogTask(time: statistics.totalLogged,
                       completionTime: residingState.totalLoggedTimeRequired,
                       dependencies: [])
    }
    
    private func createHoldTask() -> Task {
        return HoldTask(startedAt: Keychain.shared.get(.permitReceivedAt)!.date(format: .date),
                        monthsRequired: residingState.monthsRequired,
                        dependencies: [])
    }
    
    private func createBonusTask() -> Task {
        var  bonusTask =  LogTask(time: statistics.totalBonusEarned,
                                  completionTime: residingState.totalBonusAvailable,
                                  dependencies: [])
        
        bonusTask.isBonus = true
        
        return bonusTask
    }
    
    private func createHazardPerceptionTest(with dependencies: [Task] = []) -> Task {
        var perceptionTest = BasicTask(title: "Hazard Perception Test",
                                       isComplete: entries.isHazardsComplete,
                                       dependencies: dependencies)
        
        perceptionTest.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isHazardsComplete = isChecked
        }
        
        return perceptionTest
    }
    
    private func createAssessmentTask(title: String, with dependencies: [Task]) -> Task {
        var assessment = AssessmentTask(title: title,
                                        isComplete: (entries.isAssessmentComplete ?? false),
                                        completedAt: entries.assessmentCompletedAt,
                                        dependencies: dependencies)
        
        if !assessment.isActive { assessment.isComplete = false }
        
        assessment.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isAssessmentComplete = isChecked
            
            if Cache.shared.currentEntries.assessmentCompletedAt == nil {
                Cache.shared.currentEntries.assessmentCompletedAt = Date()
            }
        }
        
        assessment.editCompletionHandler = { date in
            Cache.shared.currentEntries.assessmentCompletedAt = date
        }
        
        return assessment
    }
    
    private func createDrivingTest(title: String = "Driving Test", with dependencies: [Task]) -> Task {
        var drivingTest = BasicTask(title: title,
                                    isComplete: entries.isDrivingTestComplete,
                                    dependencies: dependencies)
        
        drivingTest.checkBoxHandler = { isChecked in
            Cache.shared.currentEntries.isDrivingTestComplete = isChecked
        }
        
        return drivingTest
    }
}
