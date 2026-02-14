import ApplicationServices

enum AccessibilityPermission {
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    static func requestIfNeeded() -> Bool {
        nonisolated(unsafe) let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let options = [key: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}
