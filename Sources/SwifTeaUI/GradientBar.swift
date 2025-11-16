import SwifTeaCore

public struct GradientBar: TUIView {
    public typealias Body = Never

    private let colors: [ANSIColor]
    private let width: Int
    private let symbol: String

    public init(colors: [ANSIColor], width: Int, symbol: String = "▄") {
        self.colors = colors
        self.width = max(1, width)
        self.symbol = symbol.isEmpty ? "▄" : symbol
    }

    public var body: Never {
        fatalError("GradientBar has no body")
    }

    public func render() -> String {
        guard !colors.isEmpty else { return String(repeating: symbol, count: width) }

        let segmentCount = colors.count
        let baseSegmentWidth = max(1, width / segmentCount)
        var remaining = width
        var output = ""

        for (index, color) in colors.enumerated() {
            var chunk = baseSegmentWidth
            if index == segmentCount - 1 {
                chunk = max(chunk, remaining)
            }
            chunk = min(chunk, remaining)
            if chunk <= 0 { continue }
            output += color.rawValue + String(repeating: symbol, count: chunk)
            remaining -= chunk
        }

        if remaining > 0, let last = colors.last {
            output += last.rawValue + String(repeating: symbol, count: remaining)
        }

        return output + ANSIColor.reset.rawValue
    }
}
