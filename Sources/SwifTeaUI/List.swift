import Foundation

public struct ListRowSeparatorStyle {
    public enum Style {
        case none
        case dashed
        case line(Character)
    }

    let style: Style
    let color: ANSIColor?

    public static let none = ListRowSeparatorStyle(style: .none, color: nil)

    public static func line(color: ANSIColor? = .brightBlack) -> ListRowSeparatorStyle {
        ListRowSeparatorStyle(style: .line("─"), color: color)
    }

    public static func dashed(color: ANSIColor? = .brightBlack) -> ListRowSeparatorStyle {
        ListRowSeparatorStyle(style: .dashed, color: color)
    }
}

@resultBuilder
public enum ListRowBuilder {
    public static func buildBlock<T: TUIView>(_ components: T...) -> [AnyTUIView] {
        components.map(AnyTUIView.init)
    }
}

public struct List<Data: RandomAccessCollection, ID: Hashable>: TUIView {
    public typealias Element = Data.Element

    private let data: Data
    private let rowBuilder: (Element) -> [AnyTUIView]
    private let separatorStyle: ListRowSeparatorStyle
    private let rowSpacing: Int
    private let idResolver: (Element) -> ID

    public init(
        _ data: Data,
        id: KeyPath<Element, ID>,
        rowSpacing: Int = 0,
        separator: ListRowSeparatorStyle = .line(),
        @ListRowBuilder rows: @escaping (Element) -> [AnyTUIView]
    ) {
        self.init(
            data,
            id: { $0[keyPath: id] },
            rowSpacing: rowSpacing,
            separator: separator,
            rows: rows
        )
    }

    public init(
        _ data: Data,
        id: @escaping (Element) -> ID,
        rowSpacing: Int = 0,
        separator: ListRowSeparatorStyle = .line(),
        @ListRowBuilder rows: @escaping (Element) -> [AnyTUIView]
    ) {
        self.data = data
        self.rowBuilder = rows
        self.separatorStyle = separator
        self.rowSpacing = max(0, rowSpacing)
        self.idResolver = id
    }

    public var body: some TUIView { self }

    public func render() -> String {
        var renderedRows: [[String]] = []
        renderedRows.reserveCapacity(data.count)
        var maxWidth = 0

        for element in data {
            _ = idResolver(element)
            let rowViews = rowBuilder(element)
            let rendered = rowViews.map { $0.render() }
            let combined = rendered.joined(separator: "\n")
            let lines = combined.splitLinesPreservingEmpty()
            renderedRows.append(lines)
            let width = lines.map { HStack.visibleWidth(of: $0) }.max() ?? 0
            maxWidth = max(maxWidth, width)
        }

        var lines: [String] = []
        for (index, rowLines) in renderedRows.enumerated() {
            if rowSpacing > 0 && index > 0 {
                lines.append(contentsOf: Array(repeating: "", count: rowSpacing))
            }
            for line in rowLines {
                lines.append(line.padded(toVisibleWidth: maxWidth))
            }
            if index < renderedRows.count - 1, let separatorLine = separator(maxWidth: maxWidth) {
                lines.append(separatorLine)
            }
        }

        return lines.joined(separator: "\n")
    }

    private func separator(maxWidth: Int) -> String? {
        switch separatorStyle.style {
        case .none:
            return nil
        case .dashed:
            let pattern = "- "
            var line = ""
            while HStack.visibleWidth(of: line) < maxWidth {
                line += pattern
            }
            line = line.padded(toVisibleWidth: maxWidth)
            if let color = separatorStyle.color {
                return color.rawValue + line + ANSIColor.reset.rawValue
            }
            return line
        case .line(let character):
            let line = String(repeating: character, count: maxWidth)
            if let color = separatorStyle.color {
                return color.rawValue + line + ANSIColor.reset.rawValue
            }
            return line
        }
    }
}
