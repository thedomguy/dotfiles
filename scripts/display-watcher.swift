// Runs display-auto-mirror.sh at login, on wake, and whenever a display is
// connected or disconnected, and shows the result in a notch-style panel on
// the main display (auto-hides on success, offers Retry on failure). With the
// ultrawide gone, it relights a MacBook panel that mirror mode left at 0.
// Started by the dev.domguy.display-auto-mirror LaunchAgent.
//
// Build (needs re-running after edits):
//   swiftc -O -o ~/.local/bin/display-watcher ~/personal/dotfiles/scripts/display-watcher.swift

import AppKit
import CoreGraphics
import SwiftUI

let script = "/Users/rahul.bhatt/personal/dotfiles/scripts/display-auto-mirror.sh"
let ultrawideUUID = "DE8080FB-E78E-4446-A049-494CCC4D6C61"  // ULTRA1 in display.fish
let darkLevel: Float = 0.01     // at or below this the panel counts as off
let unpluggedLevel: Float = 0.5 // MacBook brightness once the ultrawide is gone
let runner = DispatchQueue(label: "display-watcher.runner")  // one run at a time
var pending: DispatchWorkItem?

func log(_ message: String) {
    let stamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    print("[\(stamp)] watcher: \(message)")
}

// MARK: - Display state

func onlineDisplays() -> [CGDirectDisplayID] {
    var count: UInt32 = 0
    CGGetOnlineDisplayList(0, nil, &count)
    var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
    CGGetOnlineDisplayList(count, &ids, &count)
    return Array(ids.prefix(Int(count)))
}

func uuid(of id: CGDirectDisplayID) -> String? {
    guard let u = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue() else { return nil }
    return CFUUIDCreateString(nil, u) as String
}

func ultrawide() -> CGDirectDisplayID? { onlineDisplays().first { uuid(of: $0) == ultrawideUUID } }
func builtin() -> CGDirectDisplayID? { onlineDisplays().first { CGDisplayIsBuiltin($0) != 0 } }

func isMirrored(_ a: CGDirectDisplayID, _ b: CGDirectDisplayID) -> Bool {
    CGDisplayMirrorsDisplay(a) == b || CGDisplayMirrorsDisplay(b) == a
}

// Same private API as macbook-brightness.py
typealias GetBrightness = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32
let getBrightness: GetBrightness? = {
    guard let lib = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_NOW),
          let sym = dlsym(lib, "DisplayServicesGetBrightness") else { return nil }
    return unsafeBitCast(sym, to: GetBrightness.self)
}()

typealias SetBrightness = @convention(c) (CGDirectDisplayID, Float) -> Int32
let setBrightness: SetBrightness? = {
    guard let lib = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_NOW),
          let sym = dlsym(lib, "DisplayServicesSetBrightness") else { return nil }
    return unsafeBitCast(sym, to: SetBrightness.self)
}()

func brightness(of id: CGDirectDisplayID) -> Float? {
    var value: Float = 0
    guard let get = getBrightness, get(id, &value) == 0 else { return nil }
    return value
}

// MARK: - Notch panel

enum StepState { case pending, running, done, failed }

struct Step: Identifiable {
    let id: Int
    let title: String
    var state: StepState
}

final class NotchModel: ObservableObject {
    @Published var steps: [Step] = []
    @Published var failed = false
    var onRetry: () -> Void = {}
    var onDismiss: () -> Void = {}
}

struct NotchView: View {
    @ObservedObject var model: NotchModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(model.steps) { step in
                HStack(spacing: 8) {
                    icon(step.state).frame(width: 14, height: 14)
                    Text(step.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(step.state == .pending ? 0.45 : 1))
                }
            }
            if model.failed {
                HStack(spacing: 8) {
                    pill("Retry", action: model.onRetry)
                    pill("Dismiss", action: model.onDismiss)
                }
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .frame(width: 260, alignment: .leading)
        .background(UnevenRoundedRectangle(bottomLeadingRadius: 18, bottomTrailingRadius: 18).fill(.black))
    }

    @ViewBuilder func icon(_ state: StepState) -> some View {
        switch state {
        case .pending: Image(systemName: "circle").foregroundStyle(.white.opacity(0.35))
        case .running: ProgressView().controlSize(.small).scaleEffect(0.6).tint(.white)
        case .done: Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .failed: Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        }
    }

    func pill(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(.white.opacity(0.18)))
        }
        .buttonStyle(.plain)
    }
}

// The panel never becomes key, so let the first click hit the buttons
final class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

final class Notch {
    let model = NotchModel()
    var hideTimer: DispatchWorkItem?

    lazy var panel: NSPanel = {
        let p = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        p.level = .statusBar
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = true
        p.hidesOnDeactivate = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        p.contentView = ClickThroughHostingView(rootView: NotchView(model: model))
        return p
    }()

    // Top-center of the main display (the one with the menu bar), flush with the top edge
    func layout() {
        guard let screen = NSScreen.screens.first, let view = panel.contentView else { return }
        view.layoutSubtreeIfNeeded()
        let size = view.fittingSize
        panel.setFrame(NSRect(x: screen.frame.midX - size.width / 2, y: screen.frame.maxY - size.height,
                              width: size.width, height: size.height), display: true)
    }

    func begin(_ steps: [Step]) {
        hideTimer?.cancel()
        model.failed = false
        model.steps = steps
        layout()
        if !panel.isVisible {
            panel.alphaValue = 0
            panel.orderFrontRegardless()
        }
        NSAnimationContext.runAnimationGroup { $0.duration = 0.2; panel.animator().alphaValue = 1 }
    }

    func finish(_ results: [Bool]) {
        for (i, ok) in results.enumerated() { model.steps[i + 1].state = ok ? .done : .failed }
        if results.allSatisfy({ $0 }) {
            let item = DispatchWorkItem { [weak self] in self?.hide() }
            hideTimer = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: item)
        } else {
            model.failed = true
            DispatchQueue.main.async { self.layout() }  // grow to fit the buttons
        }
    }

    func hide() {
        NSAnimationContext.runAnimationGroup({ $0.duration = 0.3; panel.animator().alphaValue = 0 },
                                             completionHandler: { self.panel.orderOut(nil) })
    }
}

let notch = Notch()

// MARK: - Running the script

// Mirror mode leaves the panel at 0; once the ultrawide is gone that's a
// black screen. Only a dark panel is touched, so a level set by hand stays.
func relightIfDark(_ reason: String) {
    guard let mb = builtin(), let level = brightness(of: mb), level <= darkLevel else {
        log("\(reason): ultrawide not connected, panel already lit")
        return
    }
    DispatchQueue.main.sync {
        notch.begin([Step(id: 0, title: "Ultrawide disconnected", state: .done),
                     Step(id: 1, title: "MacBook brightness \(Int(unpluggedLevel * 100))%", state: .running)])
    }
    _ = setBrightness?(mb, unpluggedLevel)
    usleep(300_000)  // let the panel settle before reading it back
    let lit = brightness(of: mb).map { abs($0 - unpluggedLevel) < 0.05 } ?? false
    log("\(reason): relit=\(lit)")
    DispatchQueue.main.async { notch.finish([lit]) }
}

func run(_ reason: String) {
    guard let ultra = ultrawide() else {
        relightIfDark(reason)
        return
    }

    // Judged by the actual display state, not the script's output
    let checks: [() -> Bool] = [
        { builtin().map { isMirrored($0, ultrawide() ?? ultra) } ?? false },
        { builtin().flatMap(brightness).map { $0 <= darkLevel } ?? false },
    ]
    // Steps that already hold are ticked straight away, the rest as soon as
    // polling sees them happen, so the panel never lags behind the screen
    var done = checks.map { $0() }
    DispatchQueue.main.sync {
        notch.begin([Step(id: 0, title: "Ultrawide detected", state: .done),
                     Step(id: 1, title: "Mirrored to ultrawide", state: done[0] ? .done : .running),
                     Step(id: 2, title: "MacBook dimmed", state: done[1] ? .done : .running)])
    }

    let p = Process()
    p.executableURL = URL(fileURLWithPath: script)
    p.arguments = [reason]
    do {
        try p.run()
        while p.isRunning {
            usleep(100_000)
            for (i, check) in checks.enumerated() where !done[i] && check() {
                done[i] = true
                DispatchQueue.main.async { notch.model.steps[i + 1].state = .done }
            }
        }
    } catch {
        log("couldn't start \(script): \(error)")
    }

    // The final result comes from the state once the script is done
    let results = checks.map { $0() }
    log("\(reason): mirrored=\(results[0]) dimmed=\(results[1])")
    DispatchQueue.main.async { notch.finish(results) }
}

// A single plug-in or wake fires a burst of events; restarting the timer on
// each one collapses the burst into one run once displays have settled.
func schedule(_ reason: String, after seconds: Double) {
    pending?.cancel()
    let item = DispatchWorkItem { runner.async { run(reason) } }
    pending = item
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: item)
}

notch.model.onRetry = { schedule("retry", after: 0) }
notch.model.onDismiss = { notch.hide() }

// MARK: - Triggers

// Connect/disconnect. Our own mirror switch also fires reconfiguration
// events, but not add/remove, so it can't retrigger itself.
CGDisplayRegisterReconfigurationCallback({ _, flags, _ in
    if flags.contains(.addFlag) {
        schedule("connect", after: 3)
    } else if flags.contains(.removeFlag) {
        schedule("disconnect", after: 3)
    }
}, nil)

// System wake, and display wake (panel can relight after display-only sleep)
let ws = NSWorkspace.shared.notificationCenter
for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
    ws.addObserver(forName: name, object: nil, queue: .main) { _ in
        schedule("wake", after: 5)
    }
}

setvbuf(stdout, nil, _IOLBF, 0)  // line-buffer so the log file stays in order
schedule("login", after: 10)

let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // no Dock icon, but allowed to show the panel
app.run()
