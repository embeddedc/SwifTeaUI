import Foundation

public enum SnapshotSync {
    public static let cursorBlinkerLock = NSLock()
}

public extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
