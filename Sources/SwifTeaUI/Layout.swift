import Foundation
import SwifTeaCore

public struct Spacer: TUIView {
    public typealias Body = Never

    public var body: Never {
        fatalError("Spacer has no body")
    }

    public init() {}
    public func render() -> String { " " }
}

// TODO: padding, borders, centers, width/height constraints, etc.
// For now left minimal to keep the example lean.
