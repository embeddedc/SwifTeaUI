import Testing
@testable import SwifTeaNotebookExample
import SwifTeaCore

struct NotebookSnapshotTests {

    @Test("Initial layout renders expected snapshot")
    func testInitialLayoutSnapshot() {
        let snapshot = renderInitialNotebook()
        let sanitized = snapshot.strippingANSI()

        #expect(snapshot.contains(ANSIColor.cyan.rawValue + ">▌ Welcome" + ANSIColor.reset.rawValue))

        let expected = """
        SwifTea Notebook
        [Tab] next focus | [Shift+Tab] previous | [↑/↓] choose note | [Enter] save body

        Notes           Editor                                                         
        >▌ Welcome      Title:                                                         
           Shortcuts    Welcome                                                        
           Ideas        Body:                                                          
                        Use Tab to focus fields on the right, Shift+Tab to return here.
                                                                                       
                        Saved note: Welcome                                            
                        Status: Tab to edit the welcome note.                          

        Focus: sidebar
        """

        #expect(sanitized == expected)
    }

    private func renderInitialNotebook() -> String {
        let app = NotebookApp()
        let view = app.view(model: app)
        return view.render()
    }
}

private extension String {
    func strippingANSI() -> String {
        var result = ""
        var iterator = makeIterator()
        var inEscape = false

        while let character = iterator.next() {
            if inEscape {
                if character.isANSISequenceTerminator {
                    inEscape = false
                }
                continue
            }

            if character == "\u{001B}" {
                inEscape = true
                continue
            }

            result.append(character)
        }

        return result
    }
}

private extension Character {
    var isANSISequenceTerminator: Bool {
        switch self {
        case "a"..."z", "A"..."Z":
            return true
        default:
            return false
        }
    }
}
