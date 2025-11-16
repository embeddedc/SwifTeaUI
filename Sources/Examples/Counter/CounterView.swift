import SwifTeaCore
import SwifTeaUI

struct CounterView: TUIView {
    let state: CounterState
    let focus: CounterFocusField?
    let titleBinding: Binding<String>
    let bodyBinding: Binding<String>
    let titleFocusBinding: Binding<Bool>
    let bodyFocusBinding: Binding<Bool>

    var body: some TUIView {
        MinimumTerminalSize(columns: 60, rows: 18) {
            VStack(spacing: 2, alignment: .leading) {
                VStack(spacing: 1, alignment: .leading) {
                    Text("SwifTea Counter").foregroundColor(.yellow).bold()
                    Text("Count: \(state.count)").foregroundColor(.green)
                    Text("[u] up | [d] down | [←/→] also work | [q]/[Esc]/[Ctrl-C] quit").foregroundColor(.cyan)
                    Text("[Tab] move focus forward | [Shift+Tab] move back").foregroundColor(.yellow)
                }
                .padding(1)
                .backgroundColor(.cyan)

                VStack(spacing: 1, alignment: .leading) {
                    Text("Note title:").foregroundColor(focus == .noteTitle ? .cyan : .yellow)
                    TextField("Title...", text: titleBinding)
                        .focused(titleFocusBinding)

                    Text("Note body:").foregroundColor(focus == .noteBody ? .cyan : .yellow)
                    TextField("Body...", text: bodyBinding)
                        .focused(bodyFocusBinding)

                    Text("Draft title: \(state.noteTitle)").foregroundColor(.green)
                    Text("Draft body: \(state.noteBody)").foregroundColor(.green)
                    Text("Last submitted -> title: \(state.lastSubmittedTitle), body: \(state.lastSubmittedBody)").foregroundColor(.cyan)
                    Text("Focus: \(focusDescription)").foregroundColor(.yellow)
                }
                .padding(1)
                .backgroundColor(.green)
            }
        } fallback: { size in
            VStack(spacing: 1, alignment: .leading) {
                Text("SwifTea Counter").foregroundColor(.yellow).bold()
                Border(
                    VStack(spacing: 1, alignment: .leading) {
                        Text("Need at least 60×18 characters.").foregroundColor(.yellow)
                        Text("Current size: \(size.columns)×\(size.rows)").foregroundColor(.cyan)
                        Text("Resize the terminal to keep editing your note.").foregroundColor(.green)
                    }
                )
            }
            .padding(1)
        }
    }

    private var focusDescription: String {
        switch focus {
        case .controls:
            return "controls"
        case .noteTitle:
            return "note.title"
        case .noteBody:
            return "note.body"
        case .none:
            return "none"
        }
    }
}
