import Foundation

public enum SwifTea {
    /// Bubble Tea–style runtime loop. Owns terminal, input routing, rendering.
    public static func brew<App: TUIScene>(_ app: App, fps: Int = 20) {
        var app = app
        let frameDelay = useconds_t(1_000_000 / max(1, fps))

        let actionQueue = ActionQueue<App.Action>()
        let effectRuntime = EffectRuntime(actionQueue: actionQueue)
        let originalMode = setRawMode()
        hideCursor()
        let frameLogger = FrameLogger.make()
        defer {
            showCursor()
            restoreMode(originalMode)
            effectRuntime.cancelAll()
        }
        clearScreenAndHome()
        TerminalDimensions.refresh()
        RuntimeDispatch.install(queue: actionQueue, effectRuntime: effectRuntime) {
            app.initializeEffects()

            var running = true
            var lastFrame: String? = nil
            var staticFrameStreak = 0
            let maxStaticFrames = 5
            var lastSize = TerminalDimensions.current
            var lastTime = ProcessInfo.processInfo.systemUptime

            while running {
                let now = ProcessInfo.processInfo.systemUptime
                let deltaTime = now - lastTime
                lastTime = now
                app.handleFrame(deltaTime: deltaTime)

                let size = TerminalDimensions.refresh()
                let sizeChanged = size != lastSize
                let isDrawable = size.columns > 0 && size.rows > 0
                if sizeChanged {
                    app.handleTerminalResize(from: lastSize, to: size)
                    if isDrawable {
                        clearScreenAndHome()
                    }
                }

                if isDrawable {
                    let frame = app.view(model: app.model).render()
                    let changed = frame != lastFrame
                    let forceRefresh = sizeChanged || (!changed ? (staticFrameStreak >= maxStaticFrames) : false)
                    frameLogger?.log(frame, changed: changed, forced: forceRefresh)
                    if changed || forceRefresh {
                        renderFrame(frame)
                        lastFrame = frame
                        staticFrameStreak = 0
                    } else {
                        staticFrameStreak += 1
                    }
                } else {
                    lastFrame = nil
                    staticFrameStreak = 0
                }
                lastSize = size

                if let ke = readKeyEvent(), let action = app.mapKeyToAction(ke) {
                    if app.shouldExit(for: action) {
                        running = false
                    } else {
                        app.update(action: action)
                    }
                }

                if running {
                    let pendingActions = actionQueue.drain()
                    if !pendingActions.isEmpty {
                        for action in pendingActions {
                            if app.shouldExit(for: action) {
                                running = false
                                break
                            }
                            app.update(action: action)
                        }
                    }
                }

                usleep(frameDelay)
            }
        }
    }

    public static func dispatch<Action>(_ action: Action) {
        RuntimeDispatch.dispatch(action: action)
    }

    public static func dispatch<Action>(
        _ effect: Effect<Action>,
        id: AnyHashable? = nil,
        cancelExisting: Bool = false
    ) {
        RuntimeDispatch.dispatch(effect: effect, id: id, cancelExisting: cancelExisting)
    }

    public static func cancelEffects(withID id: AnyHashable) {
        RuntimeDispatch.cancel(id: id)
    }
}
