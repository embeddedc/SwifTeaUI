import Foundation
import SwifTeaUI

/// Helpers used by the perf harness to render the gallery without widening the public API surface.
public enum GalleryPerfSupport {
    /// Returns a closure that renders the gallery scene and returns the frame text.
    /// The closure reuses a single `GalleryModel` instance to keep allocations stable.
    public static func makeRenderer() -> () -> String {
        let box = ModelBox()
        return {
            box.render()
        }
    }
}

private final class ModelBox {
    private var model = GalleryModel()

    func render() -> String {
        model.makeView().render()
    }
}
