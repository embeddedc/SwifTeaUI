public enum ANSI {
    public static let esc = "\u{001B}"
    public static let clear = "\(esc)[2J"
    public static let home  = "\(esc)[H"
    public static func color(_ code: Int) -> String { "\(esc)[\(code)m" }
    public static let reset = color(0)
}

public enum ANSIColor: String {
    case reset        = "\u{001B}[0m"
    case black        = "\u{001B}[30m"
    case red          = "\u{001B}[31m"
    case green        = "\u{001B}[32m"
    case yellow       = "\u{001B}[33m"
    case blue         = "\u{001B}[34m"
    case magenta      = "\u{001B}[35m"
    case cyan         = "\u{001B}[36m"
    case white        = "\u{001B}[37m"
    case brightBlack  = "\u{001B}[90m"
    case brightRed    = "\u{001B}[91m"
    case brightGreen  = "\u{001B}[92m"
    case brightYellow = "\u{001B}[93m"
    case brightBlue   = "\u{001B}[94m"
    case brightMagenta = "\u{001B}[95m"
    case brightCyan   = "\u{001B}[96m"
    case brightWhite  = "\u{001B}[97m"

    public var backgroundCode: String {
        switch self {
        case .reset:
            return ANSIColor.reset.rawValue
        case .black:
            return "\u{001B}[40m"
        case .red:
            return "\u{001B}[41m"
        case .green:
            return "\u{001B}[42m"
        case .yellow:
            return "\u{001B}[43m"
        case .blue:
            return "\u{001B}[44m"
        case .magenta:
            return "\u{001B}[45m"
        case .cyan:
            return "\u{001B}[46m"
        case .white:
            return "\u{001B}[47m"
        case .brightBlack:
            return "\u{001B}[100m"
        case .brightRed:
            return "\u{001B}[101m"
        case .brightGreen:
            return "\u{001B}[102m"
        case .brightYellow:
            return "\u{001B}[103m"
        case .brightBlue:
            return "\u{001B}[104m"
        case .brightMagenta:
            return "\u{001B}[105m"
        case .brightCyan:
            return "\u{001B}[106m"
        case .brightWhite:
            return "\u{001B}[107m"
        }
    }

    public var rgbComponents: (Int, Int, Int) {
        switch self {
        case .reset:
            return (0, 0, 0)
        case .black:
            return (0, 0, 0)
        case .red:
            return (205, 49, 49)
        case .green:
            return (13, 188, 121)
        case .yellow:
            return (229, 229, 16)
        case .blue:
            return (36, 114, 200)
        case .magenta:
            return (188, 63, 188)
        case .cyan:
            return (17, 168, 205)
        case .white:
            return (229, 229, 229)
        case .brightBlack:
            return (102, 102, 102)
        case .brightRed:
            return (241, 76, 76)
        case .brightGreen:
            return (35, 209, 139)
        case .brightYellow:
            return (245, 245, 67)
        case .brightBlue:
            return (59, 142, 234)
        case .brightMagenta:
            return (214, 112, 214)
        case .brightCyan:
            return (41, 184, 219)
        case .brightWhite:
            return (255, 255, 255)
        }
    }
}

extension Character {
    var isANSISequenceTerminator: Bool {
        switch self {
        case "a"..."z", "A"..."Z":
            return true
        default:
            return false
        }
    }
}
