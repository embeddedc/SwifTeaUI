import SwifTeaCore

public struct ScrollView<Content: TUIView>: TUIView {
    public enum Axis {
        case vertical
    }

    public typealias Body = Never

    private let axis: Axis
    private let viewport: Int
    private let offset: Binding<Int>
    private let pinnedToBottom: Binding<Bool>?
    private let contentLength: Binding<Int>?
    private let content: Content

    public init(
        _ axis: Axis = .vertical,
        viewport: Int,
        offset: Binding<Int>,
        pinnedToBottom: Binding<Bool>? = nil,
        contentLength: Binding<Int>? = nil,
        content: () -> Content
    ) {
        self.axis = axis
        self.viewport = max(1, viewport)
        self.offset = offset
        self.pinnedToBottom = pinnedToBottom
        self.contentLength = contentLength
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

        contentLength?.wrappedValue = lines.count
        let maxOffset = max(0, lines.count - viewport)

        var resolvedOffset = clamp(offset: offset.wrappedValue, max: maxOffset)
        if pinnedToBottom?.wrappedValue == true {
            resolvedOffset = maxOffset
        }

        if offset.wrappedValue != resolvedOffset {
            offset.wrappedValue = resolvedOffset
        }

        var visible: [String] = []
        visible.reserveCapacity(viewport)

        for index in 0..<viewport {
            let source = resolvedOffset + index
            if source < lines.count {
                visible.append(lines[source])
            } else {
                visible.append("")
            }
        }

        return visible.joined(separator: "\n")
    }

    private func clamp(offset value: Int, max: Int) -> Int {
        if value < 0 { return 0 }
        if value > max { return max }
        return value
    }
}
