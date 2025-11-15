import SwifTeaCore

public struct ScrollView<Content: TUIView>: TUIView {
    public enum Axis {
        case vertical
    }

    public typealias Body = Never

    private let axis: Axis
    private let viewport: Int
    private let offset: Binding<Int>
    private let content: Content

    public init(
        _ axis: Axis = .vertical,
        viewport: Int,
        offset: Binding<Int>,
        content: () -> Content
    ) {
        self.axis = axis
        self.viewport = max(1, viewport)
        self.offset = offset
        self.content = content()
    }

    public var body: Never {
        fatalError("ScrollView has no body")
    }

    public func render() -> String {
        switch axis {
        case .vertical:
            return renderVertical()
        }
    }

    private func renderVertical() -> String {
        var lines = content.render().splitLinesPreservingEmpty()
        if lines.isEmpty {
            lines = [""]
        }

        let clampedOffset = clampOffset(linesCount: lines.count)
        var visible: [String] = []
        visible.reserveCapacity(viewport)

        for index in 0..<viewport {
            let source = clampedOffset + index
            if source < lines.count {
                visible.append(lines[source])
            } else {
                visible.append("")
            }
        }

        return visible.joined(separator: "\n")
    }

    private func clampOffset(linesCount: Int) -> Int {
        let maxOffset = max(0, linesCount - viewport)
        var current = offset.wrappedValue
        if current < 0 {
            current = 0
        } else if current > maxOffset {
            current = maxOffset
        }
        if current != offset.wrappedValue {
            offset.wrappedValue = current
        }
        return current
    }
}
