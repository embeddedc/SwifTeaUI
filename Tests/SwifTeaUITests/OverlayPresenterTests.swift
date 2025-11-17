import Testing
@testable import SwifTeaUI

struct OverlayPresenterTests {

    @Test("Toast expires after ticking past its duration")
    func toastExpiration() {
        var presenter = OverlayPresenter()
        presenter.presentToast(duration: 1) {
            Text("Hello")
        }

        #expect(presenter.hasNotifications)
        presenter.tick(deltaTime: 0.5)
        #expect(presenter.hasNotifications)
        presenter.tick(deltaTime: 0.6)
        #expect(!presenter.hasNotifications)
    }

    @Test("Modal stack honors priority and dismiss")
    func modalPriority() {
        var presenter = OverlayPresenter()
        presenter.presentModal(priority: 1, title: "Low") {
            Text("Low")
        }
        presenter.presentModal(priority: 2, title: "High") {
            Text("High")
        }
        #expect(presenter.activeModal?.title == "High")
        presenter.dismissModal()
        #expect(presenter.activeModal?.title == "Low")
        presenter.dismissModal()
        #expect(!presenter.hasModal)
    }
}
