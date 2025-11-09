import Foundation
import Testing
@testable import SwifTeaCore

struct EffectTests {
    enum TestAction {
        case ping
    }

    @Test("Effect timer emits repeated actions until cancelled")
    func timerEmitsActions() async {
        let effect = Effect<TestAction>.timer(every: 0.01, repeats: true) { .ping }

        var emissions: [TestAction] = []
        let task = Task {
            await effect.run { action in
                emissions.append(action)
            }
        }

        try? await Task.sleep(nanoseconds: 60_000_000)
        task.cancel()
        _ = await task.result

        #expect(emissions.count >= 2)
    }
}
