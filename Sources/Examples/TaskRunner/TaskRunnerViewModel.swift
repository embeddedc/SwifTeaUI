import Foundation

struct TaskRunnerViewModel {
    func moveFocus(offset: Int, state: inout TaskRunnerState) {
        guard !state.steps.isEmpty, offset != 0 else { return }
        let count = state.steps.count
        let current = state.focusedIndex >= 0 ? state.focusedIndex : 0
        let normalizedOffset = ((offset % count) + count) % count
        let next = (current + normalizedOffset) % count
        state.focusedIndex = next
    }

    func toggleSelection(state: inout TaskRunnerState) {
        guard state.steps.indices.contains(state.focusedIndex) else { return }
        if state.selectedIndices.contains(state.focusedIndex) {
            state.selectedIndices.remove(state.focusedIndex)
        } else {
            state.selectedIndices.insert(state.focusedIndex)
        }
    }

    func selectAll(state: inout TaskRunnerState) {
        state.selectedIndices = Set(state.steps.indices)
    }

    func clearSelection(state: inout TaskRunnerState) {
        state.selectedIndices.removeAll()
    }

    func startSelected(state: inout TaskRunnerState) {
        let targets = selectionOrFocus(state: state)
        guard !targets.isEmpty else { return }

        var started: [Int] = []
        for index in targets {
            guard state.steps.indices.contains(index) else { continue }
            guard case .pending = state.steps[index].status else { continue }
            let duration = max(0.5, state.steps[index].duration)
            let run = TaskRunnerState.Step.Run(remaining: duration, total: duration)
            state.steps[index].status = .running(run)
            state.enqueueToast("Started \(state.steps[index].title)", color: .cyan, atFront: true)
            started.append(index)
        }

        if !started.isEmpty {
            state.selectedIndices.subtract(Set(started))
        }
    }

    func markFailure(state: inout TaskRunnerState) {
        let targets = selectionOrFocus(state: state)
        guard !targets.isEmpty else { return }
        var failedAny = false

        for index in targets {
            guard state.steps.indices.contains(index) else { continue }
            guard case .running = state.steps[index].status else { continue }
            failedAny = true
            let title = state.steps[index].title
            state.steps[index].status = .completed(.failure)
            state.enqueueToast("Failed \(title)", color: .yellow)
        }

        if failedAny {
            state.selectedIndices.subtract(Set(targets))
        }
    }

    func tick(state: inout TaskRunnerState, deltaTime: TimeInterval) {
        guard deltaTime > 0 else { return }
        state.tickToasts(deltaTime: deltaTime)

        var completedTitles: [String] = []
        for index in state.steps.indices {
            guard case .running(var run) = state.steps[index].status else { continue }
            run.remaining = max(0, run.remaining - deltaTime)
            if run.remaining <= 0 {
                state.steps[index].status = .completed(.success)
                completedTitles.append(state.steps[index].title)
            } else {
                state.steps[index].status = .running(run)
            }
        }

        for title in completedTitles {
            state.enqueueToast("Completed \(title)", color: .green)
        }

        if state.isComplete && !completedTitles.isEmpty {
            state.enqueueToast("All tasks complete", color: .green)
        }
    }

    func reset(state: inout TaskRunnerState) {
        for index in state.steps.indices {
            state.steps[index].status = .pending
        }
        state.selectedIndices.removeAll()
        state.focusedIndex = state.steps.isEmpty ? -1 : 0
        state.clearToasts()
        state.enqueueToast("Progress reset", color: .yellow)
    }

    private func selectionOrFocus(state: TaskRunnerState) -> [Int] {
        if !state.selectedIndices.isEmpty {
            return state.selectedIndices.sorted()
        }
        guard state.steps.indices.contains(state.focusedIndex) else { return [] }
        return [state.focusedIndex]
    }
}
