import SwifTeaCore
import SwifTeaUI

struct CounterView: TUIView {
    let state: CounterState
    let focus: CounterFocusField?
    let titleBinding: Binding<String>
    let bodyBinding: Binding<String>
    let titleFocusBinding: Binding<Bool>
    let bodyFocusBinding: Binding<Bool>
    let theme: SwifTeaTheme

    var body: some TUIView {
        MinimumTerminalSize(columns: 60, rows: 18) {
            Border(
                padding: 1,
                color: theme.frameBorder,
                bold: true,
                VStack(spacing: 2, alignment: .leading) {
                    headerPanel
                    accentDivider
                    formPanel
                }
                .padding(1)
                .backgroundColor(theme.background ?? .reset)
            )
        } fallback: { size in
            VStack(spacing: 1, alignment: .leading) {
                Text("SwifTea Counter").foregroundColor(.yellow).bold()
                Border(
                    VStack(spacing: 1, alignment: .leading) {
                        Text("Need at least 60×18 characters.").foregroundColor(.yellow)
                        Text("Current size: \(size.columns)×\(size.rows)").foregroundColor(.cyan)
                        Text("Resize the terminal to keep editing your note.").foregroundColor(.green)
                    }
                )
            }
            .padding(1)
        }
    }

    private var focusDescription: String {
        switch focus {
        case .controls:
            return "controls"
        case .noteTitle:
            return "note.title"
        case .noteBody:
            return "note.body"
        case .none:
            return "none"
        }
    }

    private var headerPanel: some TUIView {
        VStack(spacing: 1, alignment: .leading) {
            accentDivider
            Text("SwifTea Counter")
                .foregroundColor(theme.headerPanel.foreground)
                .bold()
            Text("Count: \(state.count)")
                .foregroundColor(theme.success)
            countBadge
            Text("[u] up | [d] down | [←/→] adjust | [q]/[Esc]/[Ctrl-C] quit")
                .foregroundColor(theme.mutedText)
            Text("[Tab] forward focus | [Shift+Tab] back | [t] toggle theme")
                .foregroundColor(theme.mutedText)
            Text("Theme: \(theme.name)")
                .foregroundColor(theme.info)
        }
        .padding(1)
        .backgroundColor(theme.headerPanel.background ?? .reset)
    }

    private var formPanel: some TUIView {
        VStack(spacing: 1, alignment: .leading) {
            GradientBar(
                colors: accentColors,
                width: gradientWidth,
                symbol: theme.accentGradientSymbol
            )
            Text("Note title:")
                .foregroundColor(focus == .noteTitle ? theme.accent : theme.primaryText)
            TextField("Title...", text: titleBinding)
                .focused(titleFocusBinding)

            Text("Note body:")
                .foregroundColor(focus == .noteBody ? theme.accent : theme.primaryText)
            TextField("Body...", text: bodyBinding)
                .focused(bodyFocusBinding)

            Text("Draft title: \(state.noteTitle)")
                .foregroundColor(theme.success)
            Text("Draft body: \(state.noteBody)")
                .foregroundColor(theme.success)
            Text("Last submitted -> title: \(state.lastSubmittedTitle), body: \(state.lastSubmittedBody)")
                .foregroundColor(theme.info)
            Text("Focus: \(focusDescription)")
                .foregroundColor(theme.warning)
        }
        .padding(1)
        .backgroundColor(theme.formPanel.background ?? .reset)
    }

    private var accentDivider: some TUIView {
        GradientBar(
            colors: accentColors,
            width: gradientWidth,
            symbol: theme.accentGradientSymbol
        )
    }

    private var countBadge: some TUIView {
        Border(
            padding: 0,
            color: theme.accent,
            bold: true,
            Text(" ✦ Brew score: \(state.count) ✦ ")
                .foregroundColor(theme.headerPanel.foreground)
                .backgroundColor(theme.headerPanel.background ?? .reset)
        )
    }

    private var accentColors: [ANSIColor] {
        theme.accentGradient.isEmpty ? [theme.accent] : theme.accentGradient
    }

    private var gradientWidth: Int {
        max(24, TerminalDimensions.current.columns - 10)
    }
}
