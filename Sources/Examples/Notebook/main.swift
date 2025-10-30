import Foundation
import SwifTeaCore
import SwifTeaUI

struct NotebookApp: TUIApp {
    struct Note {
        var title: String
        var body: String
    }

    enum Action {
        case selectNext
        case selectPrevious
        case focusNext
        case focusPrevious
        case setFocus(FocusTarget?)
        case editTitle(TextFieldEvent)
        case editBody(TextFieldEvent)
        case quit
    }

    enum FocusTarget: Hashable {
        case sidebar
        case editorTitle
        case editorBody
    }

    private static let globalRing = FocusRing<FocusTarget>([
        .sidebar,
        .editorTitle,
        .editorBody
    ])

    private static let editorScope = FocusScope<FocusTarget>(
        [.editorTitle, .editorBody],
        forwardWraps: false,
        backwardWraps: false
    )

    @State private var notes: [Note] = [
        Note(
            title: "Welcome",
            body: "Use Tab to focus fields on the right, Shift+Tab to return here."
        ),
        Note(
            title: "Shortcuts",
            body: "↑/↓ move between notes when the sidebar is focused. Enter on the body saves."
        ),
        Note(
            title: "Ideas",
            body: "Try wiring this data into a persistence layer or renderer diff."
        )
    ]

    @State private var selectedIndex = 0
    @State private var editorTitle = "Welcome"
    @State private var editorBody = "Use Tab to focus fields on the right, Shift+Tab to return here."
    @State private var statusMessage = "Tab to edit the welcome note."
    @FocusState private var focusedField: FocusTarget? = .sidebar

    var model: NotebookApp { self }

    mutating func update(action: Action) {
        switch action {
        case .selectNext:
            guard !notes.isEmpty else { return }
            selectedIndex = (selectedIndex + 1) % notes.count
            loadEditorFromSelection()
        case .selectPrevious:
            guard !notes.isEmpty else { return }
            selectedIndex = (selectedIndex - 1 + notes.count) % notes.count
            loadEditorFromSelection()
        case .focusNext:
            if let current = focusedField,
               Self.editorScope.contains(current),
               $focusedField.moveForward(in: Self.editorScope) {
                break
            }
            if let next = Self.globalRing.move(from: focusedField, direction: .forward) {
                focusedField = next
            } else if let first = Self.globalRing.first {
                focusedField = first
            }
        case .focusPrevious:
            if let current = focusedField,
               Self.editorScope.contains(current),
               $focusedField.moveBackward(in: Self.editorScope) {
                break
            }
            if let previous = Self.globalRing.move(from: focusedField, direction: .backward) {
                focusedField = previous
            } else if let last = Self.globalRing.last {
                focusedField = last
            }
        case .setFocus(let target):
            focusedField = target
        case .editTitle(let event):
            switch event {
            case .submit:
                focusedField = .editorBody
            case .insert, .backspace:
                $editorTitle.apply(event)
                syncCurrentNoteTitle()
            }
        case .editBody(let event):
            switch event {
            case .submit:
                syncCurrentNoteBody()
                statusMessage = "Saved \"\(editorTitle)\" at \(DateFormatter.shortTime.string(from: Date()))"
                focusedField = .sidebar
            case .insert, .backspace:
                $editorBody.apply(event)
                syncCurrentNoteBody()
            }
        case .quit:
            break
        }
    }

    func view(model: NotebookApp) -> some TUIView {
        let sidebarLines = model.notes.enumerated().map { index, note -> String in
            let pointer = index == model.selectedIndex ? ">" : " "
            let focusMarker = (model.focusedField == .sidebar && index == model.selectedIndex) ? "▌" : " "
            return "\(pointer)\(focusMarker) \(note.title)"
        }
        let sidebarBlock = sidebarLines.joined(separator: "\n")

        let focusDescription: String
        switch model.focusedField {
        case .sidebar: focusDescription = "sidebar"
        case .editorTitle: focusDescription = "editor.title"
        case .editorBody: focusDescription = "editor.body"
        case .none: focusDescription = "none"
        }

        return VStack {
            Text("SwifTea Notebook").foreground(.yellow).bolded()
            Text("[Tab] next focus | [Shift+Tab] previous | [↑/↓] choose note | [Enter] save body").foreground(.cyan)
            Text("")
            Text("Notes").foreground(.yellow)
            Text(sidebarBlock).foreground(.green)
            Text("")
            Text("Editor").foreground(.yellow)
            Text("Title:").foreground(model.focusedField == .editorTitle ? .cyan : .yellow)
            TextField("Title...", text: $editorTitle, focus: $focusedField.isFocused(.editorTitle))
            Text("Body:").foreground(model.focusedField == .editorBody ? .cyan : .yellow)
            TextField("Body...", text: $editorBody, focus: $focusedField.isFocused(.editorBody))
            Text("")
            Text("Saved note: \(model.notes[model.selectedIndex].title)").foreground(.green)
            Text("Status: \(model.statusMessage)").foreground(.cyan)
            Text("Focus: \(focusDescription)").foreground(.yellow)
        }
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .tab:
            return .focusNext
        case .backTab:
            return .focusPrevious
        case .upArrow:
            return focusedField == .sidebar ? .selectPrevious : nil
        case .downArrow:
            return focusedField == .sidebar ? .selectNext : nil
        case .enter:
            if focusedField == .sidebar {
                return .setFocus(.editorTitle)
            }
        case .char("q"), .ctrlC:
            return .quit
        default:
            break
        }

        if let event = textFieldEvent(from: key) {
            switch focusedField {
            case .editorTitle:
                return .editTitle(event)
            case .editorBody:
                return .editBody(event)
            default:
                break
            }
        }

        return nil
    }

    func shouldExit(for action: Action) -> Bool {
        if case .quit = action { return true }
        return false
    }

    // MARK: - Helpers

    private mutating func loadEditorFromSelection() {
        guard notes.indices.contains(selectedIndex) else { return }
        editorTitle = notes[selectedIndex].title
        editorBody = notes[selectedIndex].body
    }

    private mutating func syncCurrentNoteTitle() {
        guard notes.indices.contains(selectedIndex) else { return }
        notes[selectedIndex].title = editorTitle
    }

    private mutating func syncCurrentNoteBody() {
        guard notes.indices.contains(selectedIndex) else { return }
        notes[selectedIndex].body = editorBody
    }
}

private extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

@main
struct NotebookMain {
    static func main() {
        SwifTea.brew(NotebookApp(), fps: 30)
    }
}
