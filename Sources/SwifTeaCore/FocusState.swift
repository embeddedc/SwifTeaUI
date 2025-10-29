@propertyWrapper
public struct FocusState<Value: Hashable> {
    final class Storage {
        var focusedValue: Value?
        init(_ value: Value? = nil) { self.focusedValue = value }
    }

    private var storage: Storage

    public init() {
        self.storage = Storage()
    }

    public init(wrappedValue: Value?) {
        self.storage = Storage(wrappedValue)
    }

    public var wrappedValue: Value? {
        get { storage.focusedValue }
        mutating set { storage.focusedValue = newValue }
    }

    public var projectedValue: ProjectedValue {
        ProjectedValue(storage: storage)
    }

    public struct ProjectedValue {
        fileprivate let storage: Storage

        public var binding: Binding<Value?> {
            Binding<Value?>(
                get: { storage.focusedValue },
                set: { storage.focusedValue = $0 }
            )
        }

        public func isFocused(_ value: Value) -> Binding<Bool> {
            Binding<Bool>(
                get: { storage.focusedValue == value },
                set: { isFocused in
                    if isFocused {
                        storage.focusedValue = value
                    } else if storage.focusedValue == value {
                        storage.focusedValue = nil
                    }
                }
            )
        }

        public func set(_ value: Value?) {
            storage.focusedValue = value
        }

        public func clear() {
            storage.focusedValue = nil
        }

        public func move(in ring: FocusRing<Value>, direction: FocusRing<Value>.Direction) {
            storage.focusedValue = ring.move(from: storage.focusedValue, direction: direction)
        }

        public func moveForward(in ring: FocusRing<Value>) {
            move(in: ring, direction: .forward)
        }

        public func moveBackward(in ring: FocusRing<Value>) {
            move(in: ring, direction: .backward)
        }
    }
}

public struct FocusRing<Value: Hashable> {
    public enum Direction {
        case forward
        case backward
    }

    private let order: [Value]
    private let indexLookup: [Value: Int]

    public init(_ order: [Value]) {
        var unique: [Value] = []
        var seen = Set<Value>()
        for value in order where seen.insert(value).inserted {
            unique.append(value)
        }
        self.order = unique

        var lookup: [Value: Int] = [:]
        for (index, value) in unique.enumerated() {
            lookup[value] = index
        }
        self.indexLookup = lookup
    }

    public func contains(_ value: Value) -> Bool {
        indexLookup[value] != nil
    }

    public func move(from current: Value?, direction: Direction) -> Value? {
        guard !order.isEmpty else { return nil }

        guard let current = current, let currentIndex = indexLookup[current] else {
            switch direction {
            case .forward: return order.first
            case .backward: return order.last
            }
        }

        switch direction {
        case .forward:
            let nextIndex = (currentIndex + 1) % order.count
            return order[nextIndex]
        case .backward:
            let previousIndex = (currentIndex - 1 + order.count) % order.count
            return order[previousIndex]
        }
    }
}
