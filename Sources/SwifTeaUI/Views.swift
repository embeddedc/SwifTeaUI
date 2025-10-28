import Foundation
import SwifTeaCore

public struct Text: TUIView {
    let content: String
    var color: ANSIColor? = nil
    var bold: Bool = false

    public init(_ content: String) { self.content = content }

    public func foreground(_ color: ANSIColor) -> Text {
        var copy = self; copy.color = color; return copy
    }

    public func bolded() -> Text {
        var copy = self; copy.bold = true; return copy
    }

    public func render() -> String {
        var s = content
        if bold { s = "\u{001B}[1m" + s + ANSIColor.reset.rawValue }
        if let c = color { s = c.rawValue + s + ANSIColor.reset.rawValue }
        return s
    }
}

public struct VStack: TUIView {
    let children: [TUIView]

    public init(@TUIBuilder _ content: () -> [TUIView]) {
        self.children = content()
    }

    public func render() -> String {
        children.map { $0.render() }.joined(separator: "\n")
    }
}

public struct HStack: TUIView {
    let children: [TUIView]

    public init(@TUIBuilder _ content: () -> [TUIView]) {
        self.children = content()
    }

    public func render() -> String {
        children.map { $0.render() }.joined(separator: " ")
    }
}

// SwiftUI-esque result builder
@resultBuilder
public struct TUIBuilder {
    public static func buildBlock(_ components: TUIView...) -> [TUIView] { components }
}

