import SwifTeaCore
import SwifTeaUI

struct CounterApp: TUIApp {
    enum Action { case increment, decrement, quit }

    @State private var count = 0

    var model: CounterApp { self }

    mutating func update(action: Action) {
        switch action {
        case .increment: count += 1
        case .decrement: count -= 1
        case .quit: break
        }
    }

    func view(model: CounterApp) -> some TUIView {
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
