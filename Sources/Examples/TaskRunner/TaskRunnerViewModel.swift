struct TaskRunnerViewModel {
    func advance(state: inout TaskRunnerState) {
        if let runningIndex = state.activeIndex {
            let completedTitle = state.steps[runningIndex].title
            state.steps[runningIndex].status = .completed(.success)
            state.enqueueToast("Completed \(completedTitle)", color: .green)

            if state.isComplete {
                state.enqueueToast("All tasks complete", color: .green)
            } else if let nextPending = firstPendingIndex(in: state, startingAt: runningIndex + 1) {
                startStep(at: nextPending, state: &state, announceAtFront: false)
            }
        } else if let firstPending = firstPendingIndex(in: state, startingAt: 0) {
            startStep(at: firstPending, state: &state, announceAtFront: true)
        }
    }

    func markFailure(state: inout TaskRunnerState) {
        guard let runningIndex = state.activeIndex else { return }
        let failedTitle = state.steps[runningIndex].title
        state.steps[runningIndex].status = .completed(.failure)
        state.enqueueToast("Failed \(failedTitle)", color: .yellow)

        if let nextPending = firstPendingIndex(in: state, startingAt: runningIndex + 1) {
            startStep(at: nextPending, state: &state, announceAtFront: false)
        }
    }

    func reset(state: inout TaskRunnerState) {
        for index in state.steps.indices {
            state.steps[index].status = .pending
        }
        state.clearToasts()
        state.enqueueToast("Progress reset", color: .yellow)
    }

    private func startStep(at index: Int, state: inout TaskRunnerState, announceAtFront: Bool) {
        let title = state.steps[index].title
        state.steps[index].status = .running
        state.enqueueToast("Started \(title)", color: .cyan, atFront: announceAtFront)
    }

    private func firstPendingIndex(in state: TaskRunnerState, startingAt lowerBound: Int) -> Int? {
        state.steps.indices.first { $0 >= lowerBound && state.steps[$0].status == .pending }
    }
}
