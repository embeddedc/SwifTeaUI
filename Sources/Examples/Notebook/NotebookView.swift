import SwifTeaCore
import SwifTeaUI

struct NotebookView: TUIView {
    private let minimumColumns = 120
    private let minimumRows = 24

    let state: NotebookState
    let focus: NotebookFocusField?
    let titleBinding: Binding<String>
    let bodyBinding: Binding<String>
    let titleFocusBinding: Binding<Bool>
    let bodyFocusBinding: Binding<Bool>

    var body: some TUIView {
        MinimumTerminalSize(columns: minimumColumns, rows: minimumRows) {
            renderMainLayout()
        } fallback: { size in
            renderResizeMessage(for: size)
        }
    }

    private func renderMainLayout() -> some TUIView {
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
            Text("")
            HStack(spacing: 6, horizontalAlignment: .leading, verticalAlignment: .top) {
                sidebar
                editor
            }
            Text("")
            StatusBar(
                segmentSpacing: "  ",
                leading: [
                    .init("Focus: \(focusDescription)", color: .yellow)
                ],
                trailing: [
                    .init("Tab next", color: .cyan),
                    .init("Shift+Tab prev", color: .cyan),
                    .init("↑/↓ choose note", color: .cyan),
                    .init("Enter save", color: .cyan)
                ]
            )
        }
    }

    private func renderResizeMessage(for size: TerminalSize) -> some TUIView {
        let header = Text("SwifTea Notebook").foreground(.yellow).bolded()
        let message = Border(
            VStack(spacing: 1, alignment: .leading) {
                Text("Terminal too small").foreground(.yellow)
                Text("Minimum required: \(minimumColumns)×\(minimumRows)").foreground(.cyan)
                Text("Current: \(size.columns)×\(size.rows)").foreground(.cyan)
                Text("Resize the window to continue.").foreground(.green)
            }
        )

        return VStack(spacing: 1, alignment: .leading) {
            header
            Text("")
            message
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
