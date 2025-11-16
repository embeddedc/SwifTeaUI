import SwifTeaCore
import SwifTeaUI

@main
struct CounterApp: TUIApp {
    static var framesPerSecond: Int { 30 }
    var body: some TUIScene { CounterScene() }
}

struct CounterScene: TUIScene {
    typealias Model = CounterModel
    typealias Action = CounterModel.Action

    var model: CounterModel

    init(model: CounterModel = CounterModel()) {
        self.model = model
    }

    mutating func update(action: Action) {
        model.update(action: action)
    }

    func view(model: CounterModel) -> some TUIView {
        model.makeView()
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        self.model.mapKeyToAction(key)
    }

    func shouldExit(for action: Action) -> Bool {
        model.shouldExit(for: action)
    }
}

struct CounterModel {
    enum Action {
        case increment
        case decrement
        case quit
    }

    @State private var state: CounterState

    init(
        state: CounterState = CounterState()
    ) {
        self._state = State(wrappedValue: state)
    }

    mutating func update(action: Action) {
        switch action {
        case .increment:
            state.count += 1
        case .decrement:
            state.count -= 1
        case .quit:
            break
        }
    }

    func makeView() -> some TUIView {
        CounterView(count: state.count)
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .char("u"), .rightArrow: return .increment
        case .char("d"), .leftArrow:  return .decrement
        case .char("q"), .ctrlC, .escape: return .quit
        default: return nil
        }
    }

    func shouldExit(for action: Action) -> Bool {
        if case .quit = action { return true }
        return false
    }
}
