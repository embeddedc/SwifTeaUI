struct NotebookState {
    struct Note {
        var title: String
        var body: String
    }

    var notes: [Note]
    var selectedIndex: Int
    var editorTitle: String
    var editorBody: String
    var statusMessage: String

    init() {
        self.notes = [
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
        self.selectedIndex = 0
        self.editorTitle = notes[0].title
        self.editorBody = notes[0].body
        self.statusMessage = "Tab to edit the welcome note."
    }
}
