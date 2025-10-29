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
    }
}
