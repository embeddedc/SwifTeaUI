import Testing
@testable import SwifTeaUI

struct AdaptiveStackTests {

    @Test("Uses expanded layout when width exceeds breakpoint")
    func testExpandedLayout() {
        let stack = AdaptiveStack(breakpoint: 100) {
            Text("Expanded")
        } collapsed: {
            Text("Collapsed")
        }

        let output = TerminalDimensions.withTemporarySize(TerminalSize(columns: 120, rows: 30)) {
            stack.render()
        }

        #expect(output.contains("Expanded"))
        #expect(!output.contains("Collapsed"))
    }

    @Test("Uses collapsed layout below breakpoint")
    func testCollapsedLayout() {
        let stack = AdaptiveStack(breakpoint: 100) {
            Text("Expanded")
        } collapsed: {
            Text("Collapsed")
        }

        let output = TerminalDimensions.withTemporarySize(TerminalSize(columns: 80, rows: 30)) {
            stack.render()
        }

        #expect(output.contains("Collapsed"))
        #expect(!output.contains("Expanded"))
    }
}
