import AppKit
import CoreGraphics

final class MediaKeyInterceptor: @unchecked Sendable {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let onEvent: @Sendable (MediaKeyEvent) -> Void

    init(onEvent: @escaping @Sendable (MediaKeyEvent) -> Void) {
        self.onEvent = onEvent
    }

    deinit {
        stop()
    }

    func start() -> Bool {
        // NX_SYSDEFINED = 14
        let eventMask: CGEventMask = 1 << 14

        // Store self pointer for the C callback
        let userInfo = Unmanaged.passRetained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: mediaKeyCallback,
            userInfo: userInfo
        ) else {
            Unmanaged<MediaKeyInterceptor>.fromOpaque(userInfo).release()
            return false
        }

        eventTap = tap

        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) else {
            Unmanaged<MediaKeyInterceptor>.fromOpaque(userInfo).release()
            eventTap = nil
            return false
        }

        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        runLoopSource = nil
        eventTap = nil
    }

    var isRunning: Bool {
        guard let tap = eventTap else { return false }
        return CGEvent.tapIsEnabled(tap: tap)
    }

    func ensureEnabled() {
        guard let tap = eventTap, !CGEvent.tapIsEnabled(tap: tap) else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    fileprivate func handleEvent(_ event: MediaKeyEvent) {
        onEvent(event)
    }
}

private func mediaKeyCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passUnretained(event) }

    // Handle tap disabled events — re-enable the tap
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        let interceptor = Unmanaged<MediaKeyInterceptor>.fromOpaque(userInfo).takeUnretainedValue()
        interceptor.ensureEnabled()
        return Unmanaged.passUnretained(event)
    }

    // Convert CGEvent to NSEvent for easy data1 access
    guard let nsEvent = NSEvent(cgEvent: event) else {
        return Unmanaged.passUnretained(event)
    }

    // Parse via NSEvent (handles type/subtype/data1 checks)
    guard let mediaKeyEvent = MediaKeyEvent.from(nsEvent: nsEvent) else {
        return Unmanaged.passUnretained(event)
    }

    // Only intercept keyDown events (and repeats for volume), pass through keyUp
    guard mediaKeyEvent.keyState == .keyDown else {
        // Consume keyUp too so the system doesn't act on it
        return nil
    }

    let interceptor = Unmanaged<MediaKeyInterceptor>.fromOpaque(userInfo).takeUnretainedValue()
    interceptor.handleEvent(mediaKeyEvent)

    // Return nil to consume the event and suppress system HUD
    return nil
}
