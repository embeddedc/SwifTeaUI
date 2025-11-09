import Foundation
import SwifTeaCore
import SwifTeaUI

@main
struct TaskRunnerApp: TUIApp {
    static var framesPerSecond: Int { 30 }
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

    mutating func handleFrame(deltaTime: TimeInterval) {
        model.update(action: .tick(deltaTime))
    }
}

struct TaskRunnerModel {
    enum Action {
        case startSelected
        case toggleSelection
        case selectAll
        case clearSelection
        case moveFocus(Int)
        case failSelected
        case reset
        case quit
        case tick(TimeInterval)
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
        switch action {
        case .startSelected:
            viewModel.startSelected(state: &state)
        case .toggleSelection:
            viewModel.toggleSelection(state: &state)
        case .selectAll:
            viewModel.selectAll(state: &state)
        case .clearSelection:
            viewModel.clearSelection(state: &state)
        case .moveFocus(let offset):
            viewModel.moveFocus(offset: offset, state: &state)
        case .failSelected:
            viewModel.markFailure(state: &state)
        case .reset:
            viewModel.reset(state: &state)
        case .tick(let delta):
            viewModel.tick(state: &state, deltaTime: delta)
        case .quit:
            break
        }
    }

    func makeView() -> some TUIView {
        TaskRunnerView(state: state)
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .enter:
            return .startSelected
        case .char(" "):
            return .toggleSelection
        case .char("a"), .char("A"):
            return .selectAll
        case .char("c"), .char("C"):
            return .clearSelection
        case .char("f"), .char("F"):
            return .failSelected
        case .char("r"), .char("R"):
            return .reset
        case .upArrow:
            return .moveFocus(-1)
        case .downArrow:
            return .moveFocus(1)
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
