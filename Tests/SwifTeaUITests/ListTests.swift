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
}
