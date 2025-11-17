public struct OverlayHost<Content: TUIView>: TUIView {
    private let presenter: OverlayPresenter
    private let content: Content

    public init(
        presenter: OverlayPresenter,
        content: Content
    ) {
        self.presenter = presenter
        self.content = content
    }

    public init(
        presenter: OverlayPresenter,
        content: () -> Content
    ) {
        self.init(presenter: presenter, content: content())
    }

    public var body: some TUIView {
        if let modal = presenter.activeModal {
            return AnyTUIView(ModalOverlay(base: content, modal: modal))
        }

        return AnyTUIView(
            VStack(spacing: 1, alignment: .leading) {
            if !presenter.topToasts.isEmpty {
                ToastColumn(toasts: presenter.topToasts)
            }
            content
            if !presenter.bottomToasts.isEmpty {
                ToastColumn(toasts: presenter.bottomToasts)
            }
        }
        )
    }
}

private struct ToastColumn: TUIView {
    let toasts: [OverlayPresenter.ToastSnapshot]

    var body: some TUIView {
        VStack(spacing: 1, alignment: .leading) {
            ForEach(toasts) { toast in
                ToastRow(toast: toast)
            }
        }
    }
}

private struct ToastRow: TUIView {
    let toast: OverlayPresenter.ToastSnapshot

    var body: some TUIView {
        Border(
            padding: 1,
            color: toast.style.accentColor,
            background: toast.style.backgroundColor,
            HStack(spacing: 1, horizontalAlignment: .leading, verticalAlignment: .center) {
                if let icon = toast.style.icon {
                    Text(icon)
                        .foregroundColor(toast.style.accentColor)
                        .bold()
                }
                toast.view
                    .foregroundColor(toast.style.textColor)
            }
        )
    }
}

private struct ModalOverlay<Base: TUIView>: TUIView {
    let base: Base
    let modal: OverlayPresenter.ModalSnapshot

    var body: some TUIView {
        VStack(spacing: 1, alignment: .leading) {
            base.foregroundColor(.brightBlack)
            Text("")
            Border(
                padding: 2,
                color: modal.style.borderColor,
                background: .black,
                VStack(spacing: 1, alignment: .leading) {
                    if let title = modal.title {
                        Text(title)
                            .foregroundColor(modal.style.titleColor)
                            .bold()
                    }
                    modal.view
                }
            )
        }
    }
}
