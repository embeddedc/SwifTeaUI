import Foundation

public struct ZStack: TUIView {
    public enum Alignment {
        case leading
        case center
        case trailing
    }

    public typealias Body = Never

    private let layers: [any TUIView]
    private let alignment: Alignment

    public init(alignment: Alignment = .center, @TUIBuilder _ content: () -> [any TUIView]) {
        self.layers = content()
        self.alignment = alignment
    }

    public var body: Never {
        fatalError("ZStack has no body")
    }

    public func render() -> String {
        guard !layers.isEmpty else { return "" }
        var stackedLines: [String] = []

        for layer in layers {
            let render = layer.render()
            let lines = render.splitLinesPreservingEmpty()
            stackedLines = merge(top: stackedLines, overlay: lines)
        }

        return stackedLines.joined(separator: "\n")
    }

    private func merge(top base: [String], overlay: [String]) -> [String] {
        var result = base
        if overlay.count > result.count {
            result.append(contentsOf: Array(repeating: "", count: overlay.count - result.count))
        }

        for index in overlay.indices {
            let combined = mergeLine(base: result[index], overlay: overlay[index])
            result[index] = combined
        }

        return result
    }

    private func mergeLine(base: String, overlay: String) -> String {
        let baseChars = Array(base)
        let overlayChars = Array(overlay)
        let width = max(baseChars.count, overlayChars.count)
        var characters: [Character] = []
        characters.reserveCapacity(width)

        for i in 0..<width {
            let overlayChar = i < overlayChars.count ? overlayChars[i] : " "
            if overlayChar != " " {
                characters.append(overlayChar)
            } else if i < baseChars.count {
                characters.append(baseChars[i])
            } else {
                characters.append(" ")
            }
        }

        return String(characters)
    }
}
