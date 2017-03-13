
// MARK: Tasks

class Tasks {
    private let tasks = [Int: Task]()

    private let dependencies = [Int: [Int]]()
    
    private var statistics: Statistics {
        return Cache.shared.statistics
    }
    
    var count: Int {
        return tasks.count
    }

    var activeTasks: [Int] {
        var activeTasks = [Int]()
        
        for (key, task) in tasks {
            if isDependenciesComplete(for: key) && !task.isComplete {
                activeTasks.append(key)
            }
        }
        
        return activeTasks
    }
    
    // MARK: Build
    
    func buildTasks() {
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
        let firstTask = LogTask(time: statistics.totalLogged, completionTime: )
    }
    
    private func buildTasksForNewSouthWhales() {
    }
    
    private func buildTasksForQueensland() {
    }
    
    private func buildTasksForSouthAustralia() {
    }

    private func buildTasksForTasmania() {
    }
    
    private func buildTasksForWesternAustralia() {
    }
    
    // MARK: Dependencies
    
    func dependencies(for key: Int) -> [Int] {
        return dependencies[key]!
    }
    
    private func isDependenciesComplete(for key: Int) -> Bool {
        return dependencies[key]!.filter({ !tasks[$0]!.isComplete }).count == 0
    }
}
