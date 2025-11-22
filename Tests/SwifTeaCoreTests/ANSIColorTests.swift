import Testing
@testable import SwifTeaUI

@Suite
struct ANSIColorTests {

    @Test("Indexed colors emit 256-color escape codes")
    func indexedColorEscapeSequences() {
        let foreground = ANSIColor.indexed(42)
        let background = ANSIColor.indexed(99)

        #expect(foreground.rawValue == "\u{001B}[38;5;42m")
        #expect(background.backgroundCode == "\u{001B}[48;5;99m")
    }

    @Test("Truecolor escape codes use RGB triplets")
    func trueColorEscapeSequences() {
        let color = ANSIColor.trueColor(red: 12, green: 34, blue: 56)

        #expect(color.rawValue == "\u{001B}[38;2;12;34;56m")
        #expect(color.backgroundCode == "\u{001B}[48;2;12;34;56m")
    }

    @Test("RGB component mapping covers 16-color, 256-color, and truecolor modes")
    func rgbComponentMapping() {
        let basic = ANSIColor.green
        let cube = ANSIColor.indexed(196)
        let gray = ANSIColor.indexed(245)
        let direct = ANSIColor.trueColor(red: 4, green: 8, blue: 12)

        #expect(basic.rgbComponents == (13, 188, 121))
        #expect(cube.rgbComponents == (255, 0, 0))
        #expect(gray.rgbComponents == (138, 138, 138))
        #expect(direct.rgbComponents == (4, 8, 12))
    }
}
