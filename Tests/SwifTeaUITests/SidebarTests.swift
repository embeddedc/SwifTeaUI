import Testing
@testable import SwifTeaCore
@testable import SwifTeaUI

struct SidebarTests {

    @Test("Sidebar renders default indicators and colors")
    func testSidebarRendering() {
        let sidebar = Sidebar(
            title: "Notes",
            items: ["One", "Two"],
            selection: 0,
            isFocused: false
        ) { $0 }

        let expected = """
┌────────┐
│ \(ANSIColor.yellow.rawValue)Notes\(ANSIColor.reset.rawValue)  │
│ \(ANSIColor.yellow.rawValue)>  One\(ANSIColor.reset.rawValue) │
│ \(ANSIColor.green.rawValue)   Two\(ANSIColor.reset.rawValue) │
└────────┘
"""

        #expect(sidebar.render() == expected)
    }

    @Test("Sidebar highlights selection when focused")
    func testFocusedSelection() {
        let sidebar = Sidebar(
            title: "Notes",
            items: ["One", "Two"],
            selection: 1,
            isFocused: true
        ) { $0 }

        let expected = """
┌────────┐
│ \(ANSIColor.yellow.rawValue)Notes\(ANSIColor.reset.rawValue)  │
│ \(ANSIColor.green.rawValue)   One\(ANSIColor.reset.rawValue) │
│ \(ANSIColor.cyan.rawValue)>▌ Two\(ANSIColor.reset.rawValue) │
└────────┘
"""

        #expect(sidebar.render() == expected)
    }
}
