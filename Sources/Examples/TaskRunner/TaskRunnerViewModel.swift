struct TaskRunnerViewModel {
    func advance(state: inout TaskRunnerState) {
        if let runningIndex = state.activeIndex {
            state.steps[runningIndex].status = .completed(.success)
            startNext(after: runningIndex, state: &state)
        } else if let firstPending = firstPendingIndex(in: state, startingAt: 0) {
            state.steps[firstPending].status = .running
        }
    }

    func markFailure(state: inout TaskRunnerState) {
        guard let runningIndex = state.activeIndex else { return }
        state.steps[runningIndex].status = .completed(.failure)
        startNext(after: runningIndex, state: &state)
    }

    func reset(state: inout TaskRunnerState) {
        for index in state.steps.indices {
            state.steps[index].status = .pending
        }
    }

    private func startNext(after index: Int, state: inout TaskRunnerState) {
        guard let nextPending = firstPendingIndex(in: state, startingAt: index + 1) else {
            return
        }
        state.steps[nextPending].status = .running
    }

    private func firstPendingIndex(in state: TaskRunnerState, startingAt lowerBound: Int) -> Int? {
        state.steps.indices.first { $0 >= lowerBound && state.steps[$0].status == .pending }
    }
}
