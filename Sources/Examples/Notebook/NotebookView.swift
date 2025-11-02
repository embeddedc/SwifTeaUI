import SwifTeaCore
import SwifTeaUI

struct NotebookView: TUIView {
    let state: NotebookState
    let focus: NotebookFocusField?
    let titleBinding: Binding<String>
    let bodyBinding: Binding<String>
    let titleFocusBinding: Binding<Bool>
    let bodyFocusBinding: Binding<Bool>

    var body: some TUIView {
        let editorContent = VStack(spacing: 1, alignment: .leading) {
            Text("Editor").foreground(.yellow)
            Text("Title:").foreground(focus == .editorTitle ? .cyan : .yellow)
            TextField("Title...", text: titleBinding, focus: titleFocusBinding)
            Text("Body:").foreground(focus == .editorBody ? .cyan : .yellow)
            TextArea("Body...", text: bodyBinding, focus: bodyFocusBinding, width: 60)
            Text("")
            Text("Saved note: \(state.notes[state.selectedIndex].title)").foreground(.green)
            Text("Status: \(state.statusMessage)").foreground(.cyan)
        }
        let editor = Border(editorContent)

        let sidebar = Sidebar(
            title: "Notes",
            items: state.notes,
            selection: state.selectedIndex,
            isFocused: focus == .sidebar
        ) { note in
            note.title
        }

        return VStack(spacing: 1, alignment: .leading) {
            Text("SwifTea Notebook").foreground(.yellow).bolded()
            Text("[Tab] next focus | [Shift+Tab] previous | [↑/↓] choose note | [Enter] save body").foreground(.cyan)
            Text("")
            HStack(spacing: 6, horizontalAlignment: .leading, verticalAlignment: .top) {
                sidebar
                editor
            }
            Text("")
            Text("Focus: \(focusDescription)").foreground(.yellow)
        }
    }

    private var focusDescription: String {
        switch focus {
        case .sidebar:
            return "sidebar"
        case .editorTitle:
            return "editor.title"
        case .editorBody:
            return "editor.body"
        case .none:
            return "none"
        }
    }
}
