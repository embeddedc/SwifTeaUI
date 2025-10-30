import Foundation
import SwifTeaUI

struct NotebookViewModel {
    enum Effect {
        case focus(NotebookFocusField?)
    }

    func selectNext(state: inout NotebookState) {
        guard !state.notes.isEmpty else { return }
        state.selectedIndex = (state.selectedIndex + 1) % state.notes.count
        loadEditor(from: &state)
    }

    func selectPrevious(state: inout NotebookState) {
        guard !state.notes.isEmpty else { return }
        state.selectedIndex = (state.selectedIndex - 1 + state.notes.count) % state.notes.count
        loadEditor(from: &state)
    }

    func handleTitle(event: TextFieldEvent, state: inout NotebookState) -> Effect? {
        switch event {
        case .insert(let character):
            state.editorTitle.append(character)
            syncTitle(into: &state)
            return nil

        case .backspace:
            if !state.editorTitle.isEmpty {
                state.editorTitle.removeLast()
                syncTitle(into: &state)
            }
            return nil

        case .submit:
            return .focus(.editorBody)
        }
    }

    func handleBody(event: TextFieldEvent, state: inout NotebookState) -> Effect? {
        switch event {
        case .insert(let character):
            state.editorBody.append(character)
            syncBody(into: &state)
            return nil

        case .backspace:
            if !state.editorBody.isEmpty {
                state.editorBody.removeLast()
                syncBody(into: &state)
            }
            return nil

        case .submit:
            syncBody(into: &state)
            state.statusMessage = "Saved \"\(state.editorTitle)\" at \(Self.timestampFormatter.string(from: Date()))"
            return .focus(.sidebar)
        }
    }

    // MARK: - Helpers

    private func loadEditor(from state: inout NotebookState) {
        guard state.notes.indices.contains(state.selectedIndex) else { return }
        let note = state.notes[state.selectedIndex]
        state.editorTitle = note.title
        state.editorBody = note.body
    }

    private func syncTitle(into state: inout NotebookState) {
        guard state.notes.indices.contains(state.selectedIndex) else { return }
        state.notes[state.selectedIndex].title = state.editorTitle
    }

    private func syncBody(into state: inout NotebookState) {
        guard state.notes.indices.contains(state.selectedIndex) else { return }
        state.notes[state.selectedIndex].body = state.editorBody
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}
