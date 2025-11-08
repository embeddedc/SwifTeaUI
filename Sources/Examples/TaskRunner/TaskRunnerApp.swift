import SwifTeaCore
import SwifTeaUI

@main
struct TaskRunnerApp: TUIApp {
    var body: some TUIScene { TaskRunnerScene() }
}

struct TaskRunnerScene: TUIScene {
    typealias Model = TaskRunnerModel
    typealias Action = TaskRunnerModel.Action

    var model: TaskRunnerModel

    init(model: TaskRunnerModel = TaskRunnerModel()) {
        self.model = model
    }

    mutating func update(action: Action) {
        model.update(action: action)
    }

    func view(model: TaskRunnerModel) -> some TUIView {
        model.makeView()
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        self.model.mapKeyToAction(key)
    }

    func shouldExit(for action: Action) -> Bool {
        model.shouldExit(for: action)
    }
}

struct TaskRunnerModel {
    enum Action {
        case advance
        case fail
        case reset
        case quit
    }

    @State private var state: TaskRunnerState
    private let viewModel: TaskRunnerViewModel

    init(
        state: TaskRunnerState = TaskRunnerState(),
        viewModel: TaskRunnerViewModel = TaskRunnerViewModel()
    ) {
        self._state = State(wrappedValue: state)
        self.viewModel = viewModel
    }

    mutating func update(action: Action) {
        state.tickToasts()

        switch action {
        case .advance:
            viewModel.advance(state: &state)
        case .fail:
            viewModel.markFailure(state: &state)
        case .reset:
            viewModel.reset(state: &state)
        case .quit:
            break
        }
    }

    func makeView() -> some TUIView {
        TaskRunnerView(state: state)
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .enter, .char(" "):
            return .advance
        case .char("f"), .char("F"):
            return .fail
        case .char("r"), .char("R"):
            return .reset
        case .char("q"), .char("Q"), .ctrlC, .escape:
            return .quit
        default:
            return nil
        }
    }

    func shouldExit(for action: Action) -> Bool {
        if case .quit = action {
            return true
        }
        return false
    }
}
