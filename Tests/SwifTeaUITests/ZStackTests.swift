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
        #expect(rendered.contains("He++"))
    }
}
