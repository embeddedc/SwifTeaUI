import SwifTeaCore
import SwifTeaUI

struct TaskRunnerView: TUIView {
    let state: TaskRunnerState

    var body: some TUIView {
        VStack(spacing: 1, alignment: .leading) {
            Group {
                Text("SwifTea Task Runner")
                    .foregroundColor(.yellow)
                    .bold()
                    .underline()
                Text("Select multiple steps, start them together, and watch them fan out asynchronously.")
                    .foregroundColor(.cyan)
                    .italic()
            }

            Border(
                padding: 1,
                VStack(spacing: 1, alignment: .leading) {
                    Text("Process Queue")
                        .foregroundColor(.yellow)
                        .bold()
                        .underline()
                    Text(selectionSummary)
                        .foregroundColor(.cyan)
                    ForEach(Array(state.steps.enumerated()), id: \.element.id) { indexedStep in
                        StepRow(
                            index: indexedStep.offset,
                            step: indexedStep.element,
                            variant: spinnerVariant(for: indexedStep.offset),
                            isFocused: indexedStep.offset == state.focusedIndex,
                            isSelected: state.isSelected(indexedStep.offset)
                        )
                    }
                }
            )
            if state.isComplete {
                Text("All processes finished! Press [r] to reset and schedule another batch.")
                    .foregroundColor(.green)
                    .underline()
            } else {
                Text("Space toggles selection • Enter launches all selected steps • Tasks auto-complete once their timers expire.")
                    .foregroundColor(.yellow)
                    .italic()
            }
            StatusBar(
                leading: statusLeadingSegments,
                trailing: statusTrailingSegments
            )
        }
        .padding(1)
    }

    private var indexedSteps: [(offset: Int, element: TaskRunnerState.Step)] {
        Array(state.steps.enumerated())
    }

    private let spinnerVariants: [(style: Spinner.Style, label: String)] = [
        (.ascii, "ASCII"),
        (.braille, "Braille"),
        (.dots, "Dots"),
        (.line, "Line")
    ]

    private func spinnerVariant(for index: Int) -> (style: Spinner.Style, label: String) {
        spinnerVariants[index % spinnerVariants.count]
    }

    private var selectionSummary: String {
        let selected = state.selectionCount()
        let running = state.runningIndices.count
        return "\(selected) selected • \(running) running • \(state.completedCount)/\(state.totalCount) done"
    }

    private var statusLeadingSegments: [StatusBar.Segment] {
        var segments: [StatusBar.Segment] = [
            .init("Task Runner", color: .yellow)
        ]

        if let firstRunning = state.runningIndices.first {
            let variant = spinnerVariant(for: firstRunning)
            let label = "\(state.runningIndices.count) running (\(variant.label))"
            let spinnerText = Spinner(
                label: label,
                style: variant.style,
                color: .cyan,
                isBold: true
            ).render()
            segments.append(.init(spinnerText))
        } else if state.isComplete {
            segments.append(.init("All tasks complete", color: .green))
        } else {
            segments.append(.init("Idle – select steps to run", color: .cyan))
        }

        let meter = ProgressMeter(
            value: state.progressFraction,
            width: 20,
            style: .tinted(.cyan)
        ).render()
        segments.append(.init(meter))
        segments.append(.init("\(state.selectionCount()) selected", color: state.selectionCount() > 0 ? .cyan : .yellow))

        return segments
    }

    private var statusTrailingSegments: [StatusBar.Segment] {
        var segments: [StatusBar.Segment] = [
            .init("[↑/↓] move", color: .yellow),
            .init("[Space] toggle", color: .yellow),
            .init("[Enter] run", color: .yellow),
            .init("[a] all", color: .yellow),
            .init("[c] clear", color: .yellow),
            .init("[f] fail", color: .yellow),
            .init("[r] reset", color: .yellow),
            .init("[q] quit", color: .yellow)
        ]

        if let toast = state.activeToast {
            segments.append(.init("• \(toast.text)", color: toast.color))
        }

        return segments
    }

    private struct StepRow: TUIView {
        let index: Int
        let step: TaskRunnerState.Step
        let variant: (style: Spinner.Style, label: String)
        let isFocused: Bool
        let isSelected: Bool

        var body: some TUIView {
            HStack(spacing: 1, verticalAlignment: .center) {
                focusIndicator
                selectionIndicator
                Text("\(index + 1).")
                    .foregroundColor(.yellow)
                    .bold()
                Text(step.title)
                    .foregroundColor(titleColor)
                statusView
            }
        }

        private var focusIndicator: some TUIView {
            Text(isFocused ? "➤" : " ")
                .foregroundColor(isFocused ? .cyan : .yellow)
        }

        private var selectionIndicator: some TUIView {
            Text(isSelected ? "[x]" : "[ ]")
                .foregroundColor(isSelected ? .cyan : .yellow)
        }

        private var statusView: AnyTUIView {
            switch step.status {
            case .pending:
                return AnyTUIView(
                    Text("pending")
                        .foregroundColor(.yellow)
                        .italic()
                )
            case .running(let run):
                let percent = Int(run.progress * 100)
                return AnyTUIView(
                    HStack(spacing: 1, verticalAlignment: .center) {
                        Spinner(style: variant.style, color: .cyan, isBold: true)
                        Text("\(percent)%")
                            .foregroundColor(.cyan)
                            .italic()
                        ProgressMeter(
                            value: run.progress,
                            width: 12,
                            style: .tinted(.cyan)
                        )
                    }
                )
            case .completed(let result):
                let text: String
                let color: ANSIColor
                switch result {
                case .success:
                    text = "done"
                    color = .green
                case .failure:
                    text = "failed"
                    color = .yellow
                }
                return AnyTUIView(
                    Text(text)
                        .foregroundColor(color)
                        .bold()
                )
            }
        }

        private var titleColor: ANSIColor {
            switch step.status {
            case .pending:
                return .yellow
            case .running:
                return .cyan
            case .completed(.success):
                return .green
            case .completed(.failure):
                return .yellow
            }
        }
    }
}
