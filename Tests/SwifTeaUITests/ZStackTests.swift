import Testing
@testable import SwifTeaUI

struct ZStackTests {

    @Test("Overlay draws on top of base")
    func testSimpleOverlay() {
        let stack = ZStack {
            Text("Hello   ")
            Text("  ++")
        }

        let rendered = stack.render()
        #expect(rendered.contains("Hell++"))
    }

    @Test("Alignment centers overlay content")
    func testCenterAlignment() {
        let stack = ZStack(alignment: .center) {
            Text("------\n------\n------")
            Text("XX\nXX")
        }

        let lines = stack.render().split(separator: "\n").map(String.init)
        #expect(lines.count == 3)
        #expect(lines[1].contains("XX"))
    }
}
