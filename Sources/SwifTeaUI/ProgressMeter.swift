import Foundation
import SwifTeaCore

public struct ProgressMeter: TUIView {
    public typealias Body = Never

    private let value: Double
    private let width: Int
    private let fill: Character
    private let empty: Character
    private let showsPercentage: Bool

    public init(
        value: Double,
        width: Int = 16,
        fill: Character = "#",
        empty: Character = " ",
        showsPercentage: Bool = true
    ) {
        self.value = value
        self.width = max(1, width)
        self.fill = fill
        self.empty = empty
        self.showsPercentage = showsPercentage
    }

    public var body: Never {
        fatalError("ProgressMeter has no body")
    }

    public func render() -> String {
        let clamped = min(max(value, 0), 1)
        var filled = Int(clamped * Double(width))
        if clamped >= 1 {
            filled = width
        }
        let emptyCount = max(0, width - filled)

        let filledSection = String(repeating: fill, count: filled)
        let emptySection = String(repeating: empty, count: emptyCount)

        if showsPercentage {
            let percent = Int((clamped * 100).rounded())
            let formatted = String(format: "%3d%%", percent)
            return "[\(filledSection)\(emptySection)] \(formatted)"
        }

        return "[\(filledSection)\(emptySection)]"
    }
}
