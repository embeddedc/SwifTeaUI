import SwifTeaCore
import SwifTeaUI

@main
struct ColorDemoApp: TUIApp {
    static var framesPerSecond: Int { 10 }
    var body: some TUIScene { ColorDemoScene() }
}

struct ColorDemoScene: TUIScene {
    typealias Model = ColorDemoModel
    enum Action {
        case quit
    }

    var model: ColorDemoModel

    init(model: ColorDemoModel = ColorDemoModel()) {
        self.model = model
    }

    mutating func update(action: Action) {}

    func view(model: ColorDemoModel) -> some TUIView {
        model.makeView()
    }

    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch key {
        case .char("q"), .char("Q"), .escape, .ctrlC:
            return .quit
        default:
            return nil
        }
    }

    func shouldExit(for action: Action) -> Bool {
        action == .quit
    }
}

struct ColorDemoModel {
    let sampleText = "Foreground + background sample text"

    func makeView() -> some TUIView {
        ColorDemoView(sampleText: sampleText)
    }
}

struct ColorDemoView: TUIView {
    let sampleText: String

    var body: some TUIView {
        VStack(spacing: 1, alignment: .leading) {
            Text("Color Artifact Demo")
                .foregroundColor(.brightYellow)
                .bold()
            Text("Use this tiny scene to inspect resets when padding applies.")
                .foregroundColor(.brightMagenta)
            Text(sampleText)
                .foregroundColor(.brightWhite)
                .backgroundColor(.blue)
            Text("The blue background above should stop exactly at the text width.")
                .foregroundColor(.brightCyan)
            Border(
                padding: 1,
                color: .brightBlue,
                VStack(spacing: 1, alignment: .leading) {
                    Text("Border content")
                        .foregroundColor(.brightWhite)
                        .backgroundColor(.brightBlack)
                    Text("This row has a green background to expose trailing resets.")
                        .foregroundColor(.black)
                        .backgroundColor(.brightGreen)
                }
            )
        }
        .padding(1)
        .backgroundColor(.black)
    }
}
