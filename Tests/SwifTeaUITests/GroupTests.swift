import Testing
import SwifTeaCore
@testable import SwifTeaUI

struct GroupTests {
    @Test("Group concatenates conditional children without extra layout")
    func testConditionalContent() {
        let includeDetails = true

        let view = Group {
            Text("Header")
            if includeDetails {
                Text("Details")
            } else {
                Text("Fallback")
            }
            Text("Footer")
        }

        let lines = view.render().split(separator: "\n").map(String.init)
        #expect(lines == ["Header", "Details", "Footer"])
    }
}
