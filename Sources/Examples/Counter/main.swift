import SwifTeaUI
import SwifTeaCore

struct CounterApp: TUIApp {
    struct Model { var count = 0 }
    enum Action: Equatable { case increment, decrement, quit }

    var model = Model()

    mutating func update(action: Action) {
        switch action {
        case .increment: model.count += 1
        case .decrement: model.count -= 1
        case .quit: break
        }
    }

    func view(model: Model) -> some TUIView {
        VStack {
            Text("SwifTea Counter").foreground(.yellow).bolded()
            Text("Count: \(model.count)").foreground(.green)
            Text("[u] up | [d] down | [←/→] also work | [q]/[Esc]/[Ctrl-C] quit").foreground(.cyan)
        }
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .char("u"), .rightArrow: return .increment
        case .char("d"), .leftArrow:  return .decrement
        case .char("q"), .ctrlC, .escape: return .quit
        default: return nil
        }
    }

    func shouldExit(for action: Action) -> Bool { action == .quit }
}

@main
struct Main {
    static func main() {
        SwifTea.brew(CounterApp(), fps: 30)
    }
}

