import Testing
import SwifTeaCore
@testable import SwifTeaUI

struct GroupTests {
    @Test("Group concatenates conditional children without extra layout")
    func testConditionalContent() {
        let includeDetails = true
        let detail: any TUIView = includeDetails
            ? AnyTUIView(Text("Details"))
            : AnyTUIView(Text("Fallback"))

        let view = Group {
            Text("Header")
            detail
            Text("Footer")
        }

        let lines = view.render().split(separator: "\n").map(String.init)
        #expect(lines == ["Header", "Details", "Footer"])
    }
}
