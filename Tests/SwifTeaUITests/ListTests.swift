import Testing
@testable import SwifTeaUI

struct ListTests {

    @Test("List renders rows with separators")
    func testBasicList() {
        let items = ["Matcha", "Taro"]
        let list = List(items, id: \.self) { item in
            Text("• \(item)")
        }

        let rendered = list.render()
        #expect(rendered.contains("• Matcha"))
        #expect(rendered.contains("• Taro"))
    }

    @Test("List selection highlights rows and reserves focus gutters")
    func testSelectionStyles() {
        let items = [1, 2]
        let list = List(
            items,
            id: \.self,
            selection: .multiple(
                .constant([1]),
                focused: .constant(2),
                selectionStyle: TableRowStyle(backgroundColor: .magenta),
                focusedStyle: TableRowStyle(
                    foregroundColor: .yellow,
                    border: .init(leading: ">", trailing: "<", reserveSpace: true)
                )
            )
        ) { item in
            Text("Row \(item)")
        }

        let lines = list.render().split(separator: "\n").map(String.init)
        #expect(lines.count == 3)
        let firstRow = lines[0]
        let secondRow = lines[2]
        #expect(firstRow.contains(ANSIColor.magenta.backgroundCode))
        #expect(secondRow.contains(">"))
        #expect(secondRow.contains("<"))
        #expect(secondRow.contains(ANSIColor.yellow.rawValue))
    }
}
