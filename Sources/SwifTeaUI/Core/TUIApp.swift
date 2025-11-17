public protocol TUIApp {
    associatedtype Body: TUIScene
    init()
    static var framesPerSecond: Int { get }
    @TUISceneBuilder var body: Body { get }
}

public extension TUIApp where Body == Self, Self: TUIScene {
    var body: Self { self }
}

public extension TUIApp {
    static var framesPerSecond: Int { 20 }

    static func main() {
        SwifTea.brew(Self.init().body, fps: framesPerSecond)
    }
}
