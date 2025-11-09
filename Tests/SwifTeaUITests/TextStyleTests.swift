import Testing
@testable import SwifTeaUI

struct TextStyleTests {
    @Test("foregroundColor wraps content once")
    func testColor() {
        let rendered = Text("Hi").foregroundColor(.green).render()
        #expect(rendered == "\u{001B}[32mHi\u{001B}[0m")
    }

    @Test("bold wraps content once")
    func testBold() {
        let rendered = Text("Hi").bold().render()
        #expect(rendered == "\u{001B}[1mHi\u{001B}[0m")
    }

    @Test("color and bold combine regardless of modifier order")
    func testColorAndBold() {
        let first = Text("Hi").foregroundColor(.yellow).bold().render()
        let second = Text("Hi").bold().foregroundColor(.yellow).render()
        let expected = "\u{001B}[33m\u{001B}[1mHi\u{001B}[0m"
        #expect(first == expected)
        #expect(second == expected)
    }

    @Test("italic wraps content once")
    func testItalic() {
        let rendered = Text("Hi").italic().render()
        #expect(rendered == "\u{001B}[3mHi\u{001B}[0m")
    }

    @Test("underline wraps content once")
    func testUnderline() {
        let rendered = Text("Hi").underline().render()
        #expect(rendered == "\u{001B}[4mHi\u{001B}[0m")
    }

    @Test("background color wraps content once")
    func testBackgroundColor() {
        let rendered = Text("Hi").backgroundColor(.cyan).render()
        #expect(rendered == "\u{001B}[46mHi\u{001B}[0m")
    }

    @Test("bold color italic combine")
    func testAllStyles() {
        let rendered = Text("Hi")
            .foregroundColor(.cyan)
            .bold()
            .italic()
            .render()
        #expect(rendered == "\u{001B}[36m\u{001B}[1m\u{001B}[3mHi\u{001B}[0m")
    }

    @Test("full chain includes underline")
    func testAllStylesWithUnderline() {
        let rendered = Text("Hi")
            .underline()
            .bold()
            .foregroundColor(.yellow)
            .italic()
            .render()
        #expect(rendered == "\u{001B}[33m\u{001B}[1m\u{001B}[3m\u{001B}[4mHi\u{001B}[0m")
    }

    @Test("full chain includes background color")
    func testAllStylesWithBackground() {
        let rendered = Text("Hi")
            .foregroundColor(.green)
            .backgroundColor(.yellow)
            .bold()
            .italic()
            .underline()
            .render()
        #expect(rendered == "\u{001B}[32m\u{001B}[43m\u{001B}[1m\u{001B}[3m\u{001B}[4mHi\u{001B}[0m")
    }
}
