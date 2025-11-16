import SwifTeaCore
import SwifTeaUI

struct CounterView: TUIView {
    let count: Int

    var body: some TUIView {
        MinimumTerminalSize(columns: 40, rows: 8) {
            Border(
                padding: 1,
                color: .brightMagenta,
                VStack(spacing: 1, alignment: .leading) {
                    Text("SwifTea Counter")
                        .foregroundColor(.brightYellow)
                        .bold()
                    Text("Count: \(count)")
                        .foregroundColor(.brightGreen)
                    Text("[←/d] decrement | [→/u] increment")
                        .foregroundColor(.brightCyan)
                    Text("[q]/[Esc]/[Ctrl-C] quits")
                        .foregroundColor(.brightBlue)
                }
            )
        } fallback: { size in
            VStack(spacing: 1, alignment: .leading) {
                Text("Need at least 40×8 characters.")
                    .foregroundColor(.brightYellow)
                Text("Current size: \(size.columns)×\(size.rows)")
                    .foregroundColor(.brightCyan)
            }
            .padding(1)
        }
    }
}
