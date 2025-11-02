import Testing
@testable import SwifTeaCore
@testable import SwifTeaUI

struct BorderTests {

    @Test("Border applies a default padding of one space on each side")
    func testDefaultPadding() {
        let bordered = Border(Text("Hi"))
        #expect(bordered.render() == """
┌────┐
│ Hi │
└────┘
""")
    }

    @Test("Border renders without padding when configured with zero")
    func testZeroPadding() {
        let bordered = Border(padding: 0, Text("Hi"))
        #expect(bordered.render() == """
┌──┐
│Hi│
└──┘
""")
    }

    @Test("border modifier forwards padding to the border view")
    func testBorderModifierPadding() {
        let view = Text("Hi").border(padding: 0)
        let expected = Border(padding: 0, Text("Hi")).render()
        #expect(view.render() == expected)
    }

    @Test("Focus ring styling colors only the border characters")
    func testFocusRingStyling() {
        let style = FocusStyle(indicator: "> ", color: .cyan, bold: true)
        let border = FocusRingBorder(padding: 0, isFocused: true, style: style, Text("Hi"))
        let lines = border.render().split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let prefix = ANSIColor.cyan.rawValue + "\u{001B}[1m"
        let reset = ANSIColor.reset.rawValue

        #expect(lines.count == 3)
        #expect(lines[0] == prefix + "┌──┐" + reset)
        #expect(lines[1] == prefix + "│" + reset + "Hi" + prefix + "│" + reset)
        #expect(lines[2] == prefix + "└──┘" + reset)
        #expect(!lines.joined(separator: "\n").contains("> "))
    }

    @Test("Focus ring skips styling when view is not focused")
    func testFocusRingUnfocused() {
        let style = FocusStyle(indicator: "", color: .cyan, bold: true)
        let border = FocusRingBorder(padding: 0, isFocused: false, style: style, Text("Hi"))
        let expected = """
┌──┐
│Hi│
└──┘
"""
        #expect(border.render() == expected)
    }
}
