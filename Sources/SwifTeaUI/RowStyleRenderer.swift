import Foundation

enum RowStyleRenderer {
    static func apply(
        style: TableRowStyle?,
        to line: String,
        totalWidth: Int,
        reservedLeading: Int,
        reservedTrailing: Int
    ) -> String {
        let guttered = addGutters(to: line, reservedLeading: reservedLeading, reservedTrailing: reservedTrailing)

        guard let style else { return enforceVisibleWidth(guttered, width: totalWidth) }

        var decoratedLine = guttered
        if let border = style.border {
            let targetLine = border.reserveSpace ? line : guttered
            decoratedLine = overlayBorder(
                targetLine,
                border: border,
                width: totalWidth,
                reservedLeading: reservedLeading,
                reservedTrailing: reservedTrailing
            )
        }

        var prefix = ""
        if let fg = style.foregroundColor {
            prefix += fg.rawValue
        }
        if let bg = style.backgroundColor {
            prefix += bg.backgroundCode
        }
        if style.isBold {
            prefix += "\u{001B}[1m"
        }
        if style.isUnderlined {
            prefix += "\u{001B}[4m"
        }
        if style.isDimmed {
            prefix += "\u{001B}[2m"
        }
        if style.isReversed {
            prefix += "\u{001B}[7m"
        }
        if !prefix.isEmpty {
            decoratedLine = prefix + decoratedLine + ANSIColor.reset.rawValue
        }

        return enforceVisibleWidth(decoratedLine, width: totalWidth)
    }

    static func enforceVisibleWidth(_ line: String, width: Int) -> String {
        guard width > 0 else { return "" }

        let currentWidth = HStack.visibleWidth(of: line)
        if currentWidth == width {
            return line
        } else if currentWidth < width {
            return line + String(repeating: " ", count: width - currentWidth)
        }

        // Trim to the requested width while preserving ANSI sequences.
        var visibleIndex = 0
        var produced = 0
        var result = ""
        var pendingSequences = ""
        var index = line.startIndex
        var inEscape = false
        var currentSequence = ""

        while index < line.endIndex {
            let character = line[index]
            if inEscape {
                currentSequence.append(character)
                if character.isANSISequenceTerminator {
                    inEscape = false
                    // keep sequences even if we don't emit visible chars yet
                    if produced < width {
                        result.append(currentSequence)
                    } else {
                        pendingSequences.append(currentSequence)
                    }
                    currentSequence.removeAll(keepingCapacity: true)
                }
            } else if character == "\u{001B}" {
                inEscape = true
                currentSequence = "\u{001B}"
            } else {
                if produced < width {
                    if !pendingSequences.isEmpty {
                        result.append(pendingSequences)
                        pendingSequences.removeAll(keepingCapacity: true)
                    }
                    result.append(character)
                    produced += 1
                }
                visibleIndex += 1
                if produced >= width && !inEscape {
                    // discard remaining visible characters
                    // but continue consuming escapes to keep index advancing
                }
            }
            index = line.index(after: index)
            if produced >= width && !inEscape {
                // We can break early once we hit the width and not inside escape.
                break
            }
        }

        if !result.hasSuffix(ANSIColor.reset.rawValue) {
            result += ANSIColor.reset.rawValue
        }
        return result
    }

    static func gutterLeading(for style: TableRowStyle?) -> Int {
        guard let border = style?.border, border.reserveSpace else { return 0 }
        return HStack.visibleWidth(of: border.leading)
    }

    static func gutterTrailing(for style: TableRowStyle?) -> Int {
        guard let border = style?.border, border.reserveSpace else { return 0 }
        return HStack.visibleWidth(of: border.trailing)
    }

    private static func addGutters(to line: String, reservedLeading: Int, reservedTrailing: Int) -> String {
        let leading = reservedLeading > 0 ? String(repeating: " ", count: reservedLeading) : ""
        let trailing = reservedTrailing > 0 ? String(repeating: " ", count: reservedTrailing) : ""
        return leading + line + trailing
    }

    private static func overlayBorder(
        _ line: String,
        border: TableRowStyle.Border,
        width: Int,
        reservedLeading: Int,
        reservedTrailing: Int
    ) -> String {
        guard width > 0 else { return line }
        let leadingWidth = HStack.visibleWidth(of: border.leading)
        let trailingWidth = HStack.visibleWidth(of: border.trailing)

        // Reserve gutters when requested to avoid covering content.
        if border.reserveSpace {
            let contentWidth = max(0, width - reservedLeading - reservedTrailing)
            let content = enforceVisibleWidth(line, width: contentWidth)
            let leading = padBorderSegment(border.leading, to: reservedLeading)
            let trailing = padBorderSegment(border.trailing, to: reservedTrailing)
            return leading + content + trailing
        }

        var result = line
        if leadingWidth > 0 {
            result = border.leading + dropLeadingVisibleColumns(from: result, count: leadingWidth)
        }

        if trailingWidth > 0 {
            let keepWidth = max(0, width - trailingWidth)
            result = takeLeadingVisibleColumns(from: result, count: keepWidth) + border.trailing
        }

        return enforceVisibleWidth(result, width: width)
    }

    private static func padBorderSegment(_ segment: String, to width: Int) -> String {
        guard width > 0 else { return "" }
        let current = HStack.visibleWidth(of: segment)
        if current == width { return segment }
        if current < width {
            return segment + String(repeating: " ", count: width - current)
        }
        return takeLeadingVisibleColumns(from: segment, count: width)
    }

    private static func dropLeadingVisibleColumns(from line: String, count: Int) -> String {
        guard count > 0 else { return line }

        var visibleIndex = 0
        var capturing = false
        var result = ""
        var pendingSequences = ""
        var index = line.startIndex
        var inEscape = false
        var currentSequence = ""

        while index < line.endIndex {
            let character = line[index]
            if inEscape {
                currentSequence.append(character)
                if character.isANSISequenceTerminator {
                    inEscape = false
                    if capturing {
                        result.append(currentSequence)
                    } else {
                        pendingSequences.append(currentSequence)
                    }
                    currentSequence.removeAll(keepingCapacity: true)
                }
            } else if character == "\u{001B}" {
                inEscape = true
                currentSequence = "\u{001B}"
            } else {
                if visibleIndex >= count {
                    if !capturing {
                        capturing = true
                        if !pendingSequences.isEmpty {
                            result.append(pendingSequences)
                            pendingSequences.removeAll(keepingCapacity: true)
                        }
                    }
                    result.append(character)
                }
                visibleIndex += 1
            }
            index = line.index(after: index)
        }

        return capturing ? result : ""
    }

    private static func takeLeadingVisibleColumns(from line: String, count: Int) -> String {
        guard count > 0 else { return "" }

        var visibleIndex = 0
        var produced = 0
        var result = ""
        var index = line.startIndex
        var inEscape = false
        var currentSequence = ""

        while index < line.endIndex {
            let character = line[index]
            if inEscape {
                currentSequence.append(character)
                if character.isANSISequenceTerminator {
                    inEscape = false
                    result.append(currentSequence)
                    currentSequence.removeAll(keepingCapacity: true)
                }
            } else if character == "\u{001B}" {
                inEscape = true
                currentSequence = "\u{001B}"
            } else {
                if produced < count {
                    result.append(character)
                    produced += 1
                } else {
                    break
                }
                visibleIndex += 1
            }
            index = line.index(after: index)
        }

        if produced < count {
            result += String(repeating: " ", count: count - produced)
        }
        return result
    }
}
