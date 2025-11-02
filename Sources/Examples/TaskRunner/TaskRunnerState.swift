import SwifTeaCore

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

    struct Toast: Equatable {
        var text: String
        var color: ANSIColor
        var ttl: Int
    }

    var steps: [Step] = [
        Step(title: "Fetch configuration", status: .pending),
        Step(title: "Run analysis", status: .pending),
        Step(title: "Write summary", status: .pending),
        Step(title: "Publish artifacts", status: .pending)
    ]

    private let maxToasts = 3
    var toasts: [Toast] = []
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

    var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    mutating func enqueueToast(_ text: String, color: ANSIColor, ttl: Int = 6, atFront: Bool = true) {
        let message = Toast(text: text, color: color, ttl: ttl)
        if atFront {
            toasts.insert(message, at: 0)
        } else {
            toasts.append(message)
        }
        if toasts.count > maxToasts {
            toasts.removeLast()
        }
    }

    mutating func tickToasts() {
        guard !toasts.isEmpty else { return }
        for index in toasts.indices {
            toasts[index].ttl -= 1
        }
        toasts.removeAll { $0.ttl <= 0 }
    }

    mutating func clearToasts() {
        toasts.removeAll()
    }

    var activeToast: Toast? {
        toasts.first
    }
}
