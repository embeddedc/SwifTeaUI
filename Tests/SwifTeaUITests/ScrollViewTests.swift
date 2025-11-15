import Testing
import SwifTeaCore
@testable import SwifTeaUI

struct ScrollViewTests {
    @Test("Vertical ScrollView clamps offset and renders visible window")
    func testVerticalScrolling() {
        let content = (1...6).map { "Line \($0)" }.joined(separator: "\n")
        var offset = 4
        let binding = Binding<Int>(
            get: { offset },
            set: { offset = $0 }
        )

        let view = ScrollView(viewport: 3, offset: binding) {
            Text(content)
        }

        let lines = view.render().split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        #expect(lines == ["Line 4", "Line 5", "Line 6"])
        #expect(offset == 3)
    }

    @Test("ScrollView pads when content shorter than viewport")
    func testViewportPadding() {
        var offset = 0
        let binding = Binding<Int>(
            get: { offset },
            set: { offset = $0 }
        )
        let view = ScrollView(viewport: 4, offset: binding) {
            Text("Only one line")
        }

        let lines = view.render().split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        #expect(lines == ["Only one line", "", "", ""])
    }
}
