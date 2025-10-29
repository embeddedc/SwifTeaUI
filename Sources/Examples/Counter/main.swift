import SwifTeaCore
import SwifTeaUI

struct CounterApp: TUIApp {
    enum Action {
        case increment
        case decrement
        case quit
        case edit(TextFieldEvent)
        case focus(FocusTarget?)
    }

    enum FocusTarget: Hashable {
        case controls
        case note
    }

    @State private var count = 0
    @State private var note = ""
    @State private var lastSubmittedNote = ""
    @FocusState private var focusedField: FocusTarget? = .controls

    var model: CounterApp { self }

    mutating func update(action: Action) {
        switch action {
        case .increment: count += 1
        case .decrement: count -= 1
        case .edit(let event):
            switch event {
            case .submit:
                lastSubmittedNote = note
                note = ""
                focusedField = .controls
            case .insert, .backspace:
                $note.apply(event)
            }
        case .focus(let target):
            focusedField = target
        case .quit: break
        }
    }

    func view(model: CounterApp) -> some TUIView {
        let focusLabel = (model.focusedField == .note) ? "note" : "controls"
        return VStack {
            Text("SwifTea Counter").foreground(.yellow).bolded()
            Text("Count: \(model.count)").foreground(.green)
            Text("[u] up | [d] down | [←/→] also work | [q]/[Esc]/[Ctrl-C] quit").foreground(.cyan)
            Spacer()
            Text("Type a note and press Enter:").foreground(.yellow)
            TextField("Your note...", text: $note, focus: $focusedField.isFocused(.note))
            Text("Draft: \(model.note)").foreground(.green)
            Text("Last submitted: \(model.lastSubmittedNote)").foreground(.cyan)
            Text("Focus: \(focusLabel)").foreground(.yellow)
        }
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        if focusedField == .note, let textEvent = textFieldEvent(from: key) {
            return .edit(textEvent)
        }
        switch key {
        case .char("u"), .rightArrow: return .increment
        case .char("d"), .leftArrow:  return .decrement
        case .tab:
            let nextFocus: FocusTarget? = (focusedField == .note) ? .controls : .note
            return .focus(nextFocus)
        case .char("q"), .ctrlC, .escape: return .quit
        default: return nil
        }
    }

    func shouldExit(for action: Action) -> Bool {
        if case .quit = action { return true }
        return false
    }
}

@main
struct Main {
    static func main() {
        SwifTea.brew(CounterApp(), fps: 30)
    }
}
