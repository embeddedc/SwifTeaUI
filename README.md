# SwifTeaUI 🍵

A modern, declarative **Terminal UI framework for Swift**, inspired by SwiftUI and Bubble Tea.

### Goals

✅ SwiftUI-like declarative syntax  
✅ POSIX & ANSI abstractions handled for you  
✅ Async actions, effects, and key event routing  
✅ Cross-platform (macOS + Linux)  
✅ Clean, composable view system

### Example

```swift
struct CounterApp: TUIApp {
    // ...
}
@main struct Main {
    static func main() {
        SwifTea.brew(CounterApp())
    }
}
Written in Swift.
