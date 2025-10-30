import SwifTeaCore
import SwifTeaUI

struct CounterApp: TUIApp {
    enum Action {
        case increment
        case decrement
        case quit
        case editTitle(TextFieldEvent)
        case editBody(TextFieldEvent)
        case setFocus(FocusTarget?)
        case focusNext
        case focusPrevious
    }

    enum FocusTarget: Hashable {
        case controls
        case noteTitle
        case noteBody
    }

    private static let globalFocusRing = FocusRing<FocusTarget>([
        .controls,
        .noteTitle,
        .noteBody
    ])

    private static let noteScope = FocusScope<FocusTarget>(
        [.noteTitle, .noteBody],
        forwardWraps: false,
        backwardWraps: false
    )

    @State private var count = 0
    @State private var noteTitle = ""
    @State private var noteBody = ""
    @State private var lastSubmittedTitle = ""
    @State private var lastSubmittedBody = ""
    @FocusState private var focusedField: FocusTarget? = .controls

    var model: CounterApp { self }

    mutating func update(action: Action) {
        switch action {
        case .increment: count += 1
        case .decrement: count -= 1
        case .editTitle(let event):
            switch event {
            case .submit:
                focusedField = .noteBody
            case .insert, .backspace:
                $noteTitle.apply(event)
            }
        case .editBody(let event):
            switch event {
            case .submit:
                lastSubmittedTitle = noteTitle
                lastSubmittedBody = noteBody
                noteTitle = ""
                noteBody = ""
                focusedField = .controls
            case .insert, .backspace:
                $noteBody.apply(event)
            }
        case .setFocus(let target):
            focusedField = target
        case .focusNext:
            if $focusedField.moveForward(in: Self.noteScope) { break }
            if let next = Self.globalFocusRing.move(from: focusedField, direction: .forward) {
                focusedField = next
            }
        case .focusPrevious:
            if $focusedField.moveBackward(in: Self.noteScope) { break }
            if let previous = Self.globalFocusRing.move(from: focusedField, direction: .backward) {
                focusedField = previous
            }
        case .quit: break
        }
    }

    func view(model: CounterApp) -> some TUIView {
        let focusDescription: String
        switch model.focusedField {
        case .controls: focusDescription = "controls"
        case .noteTitle: focusDescription = "note.title"
        case .noteBody: focusDescription = "note.body"
        case .none: focusDescription = "none"
        }

        return VStack {
            Text("SwifTea Counter").foreground(.yellow).bolded()
            Text("Count: \(model.count)").foreground(.green)
            Text("[u] up | [d] down | [←/→] also work | [q]/[Esc]/[Ctrl-C] quit").foreground(.cyan)
            Text("[Tab] move focus forward | [Shift+Tab] move back").foreground(.yellow)
            Spacer()
            Text("Note title:").foreground(.yellow)
            TextField("Title...", text: $noteTitle, focus: $focusedField.isFocused(.noteTitle))
            Text("Note body:").foreground(.yellow)
            TextField("Body...", text: $noteBody, focus: $focusedField.isFocused(.noteBody))
            Text("Draft title: \(model.noteTitle)").foreground(.green)
            Text("Draft body: \(model.noteBody)").foreground(.green)
            Text("Last submitted -> title: \(model.lastSubmittedTitle), body: \(model.lastSubmittedBody)").foreground(.cyan)
            Text("Focus: \(focusDescription)").foreground(.yellow)
        }
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .tab:
            return .focusNext
        case .backTab:
            return .focusPrevious
        default:
            break
        }

        if let textEvent = textFieldEvent(from: key) {
            switch focusedField {
            case .noteTitle:
                return .editTitle(textEvent)
            case .noteBody:
                return .editBody(textEvent)
            default:
                break
            }
        }

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

@main
struct Main {
    static func main() {
        SwifTea.brew(CounterApp(), fps: 30)
    }
}
