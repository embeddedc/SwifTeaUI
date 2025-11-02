struct TaskRunnerState {
    struct Step: Equatable {
        enum Status: Equatable {
            enum Result: Equatable {
                case success
                case failure
            }

            case pending
            case running
            case completed(Result)
        }

        var title: String
        var status: Status
    }

    var steps: [Step] = [
        Step(title: "Fetch configuration", status: .pending),
        Step(title: "Run analysis", status: .pending),
        Step(title: "Write summary", status: .pending)
    ]
}

extension TaskRunnerState {
    var activeIndex: Int? {
        steps.firstIndex { step in
            if case .running = step.status { return true }
            return false
        }
    }

    var activeStep: Step? {
        activeIndex.map { steps[$0] }
    }

    var completedCount: Int {
        steps.reduce(into: 0) { count, step in
            if case .completed = step.status {
                count += 1
            }
        }
    }

    var totalCount: Int {
        steps.count
    }

    var isComplete: Bool {
        completedCount == totalCount && totalCount > 0
    }
}
