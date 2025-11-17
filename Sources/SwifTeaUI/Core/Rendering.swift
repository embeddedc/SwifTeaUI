import Foundation

final class FrameLogger {
    private let handle: FileHandle
    private var frameIndex: Int = 0

    private init?(path: String) {
        let manager = FileManager.default
        if manager.fileExists(atPath: path) {
            try? manager.removeItem(atPath: path)
        }

        manager.createFile(atPath: path, contents: nil, attributes: nil)

        guard let handle = FileHandle(forWritingAtPath: path) else {
            return nil
        }

        self.handle = handle
    }

    deinit {
        try? handle.close()
    }

    static func make() -> FrameLogger? {
        guard let path = ProcessInfo.processInfo.environment["SWIFTEA_FRAME_LOG"],
              !path.isEmpty else { return nil }
        return FrameLogger(path: path)
    }

    func log(_ frame: String, changed: Bool, forced: Bool) {
        frameIndex += 1
        let header = "\n--- frame \(frameIndex) (changed: \(changed) forced: \(forced)) ---\n"
        guard let headerData = header.data(using: .utf8),
              let frameData = frame.data(using: .utf8),
              let newline = "\n".data(using: .utf8) else { return }

        do {
            try handle.seekToEnd()
            try handle.write(contentsOf: headerData)
            try handle.write(contentsOf: frameData)
            try handle.write(contentsOf: newline)
        } catch {
            // Best-effort logging; ignore write failures.
        }
    }
}

@inline(__always)
func moveCursorHome() {
    writeToStdout("\u{001B}[H")
}

@inline(__always)
func clearBelowCursor() {
    writeToStdout("\u{001B}[J")
}

@inline(__always)
func renderFrame(_ frame: String) {
    moveCursorHome()
    let columns = TerminalDimensions.current.columns
    if columns > 0 {
        writeToStdout(frame.padded(toVisibleWidth: columns))
    } else {
        writeToStdout(frame)
    }
    clearBelowCursor()
    fflush(stdout)
}

@inline(__always)
func writeToStdout(_ string: String) {
    guard !string.isEmpty, let data = string.data(using: .utf8) else { return }
    try? FileHandle.standardOutput.write(contentsOf: data)
}

extension String {
    func padded(toVisibleWidth width: Int) -> String {
        guard width > 0 else { return self }

        var result = String()
        result.reserveCapacity(count + width)

        var currentWidth = 0
        var inEscape = false

        for character in self {
            if character == "\n" {
                if currentWidth < width {
                    result.append(ANSIColor.reset.rawValue)
                    result.append(String(repeating: " ", count: width - currentWidth))
                }
                result.append(character)
                currentWidth = 0
                inEscape = false
                continue
            }

            if character == "\u{001B}" {
                inEscape = true
            } else if inEscape {
                if character.isANSISequenceTerminator {
                    inEscape = false
                }
            } else {
                currentWidth += 1
            }

            result.append(character)
        }

        if currentWidth < width {
            result.append(ANSIColor.reset.rawValue)
            result.append(String(repeating: " ", count: width - currentWidth))
        }

        return result
    }
}
