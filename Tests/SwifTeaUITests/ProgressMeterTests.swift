import Foundation
import Testing
@testable import SwifTeaCore
@testable import SwifTeaUI

struct ProgressMeterTests {

    @Test("Progress meter shows zero percent with empty bar")
    func testZeroProgress() {
        let meter = ProgressMeter(value: 0, width: 10, fill: "#", empty: ".")
        #expect(meter.render() == "[..........]   0%")
    }

    @Test("Progress meter clamps value into range")
    func testClampedProgress() {
        let meter = ProgressMeter(value: 1.5, width: 5, fill: "*", empty: "-")
        #expect(meter.render() == "[*****] 100%")
    }

    @Test("Progress meter renders intermediate percentage")
    func testIntermediateProgress() {
        let meter = ProgressMeter(value: 0.42, width: 10, fill: "=")
        #expect(meter.render() == "[====      ]  42%")
    }
}
