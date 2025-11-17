import Foundation

public protocol TUIView {
    associatedtype Body: TUIView
    var body: Body { get }
    func render() -> String
}

public extension TUIView {
    func render() -> String {
        body.render()
    }
}

extension Never: TUIView {
    public typealias Body = Never

    public var body: Never {
        fatalError("Never has no body")
    }

    public func render() -> String {
        fatalError("Never cannot render")
    }
}

public protocol TUIScene {
    associatedtype Model = Self
    associatedtype Action = Never
    associatedtype Content: TUIView

    var model: Model { get }
    func view(model: Model) -> Content

    mutating func update(action: Action)
    mutating func initializeEffects()
    mutating func handleTerminalResize(from oldSize: TerminalSize, to newSize: TerminalSize)
    func mapKeyToAction(_ key: KeyEvent) -> Action?
    func shouldExit(for action: Action) -> Bool
    mutating func handleFrame(deltaTime: TimeInterval)
}

@resultBuilder
public enum TUISceneBuilder {
    public static func buildBlock<Content: TUIScene>(_ content: Content) -> Content {
        content
    }
}

public extension TUIScene {
    mutating func initializeEffects() {}
    mutating func handleTerminalResize(from oldSize: TerminalSize, to newSize: TerminalSize) {}
    mutating func handleFrame(deltaTime: TimeInterval) {}
}
