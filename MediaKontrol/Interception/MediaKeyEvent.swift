import AppKit

struct MediaKeyEvent: Sendable {
    enum KeyType: Sendable {
        case play
        case next
        case previous
        case soundUp
        case soundDown
    }

    enum KeyState: Sendable {
        case keyDown
        case keyUp
    }

    let keyType: KeyType
    let keyState: KeyState
    let isRepeat: Bool

    static func from(nsEvent: NSEvent) -> MediaKeyEvent? {
        guard nsEvent.type == .systemDefined,
              nsEvent.subtype.rawValue == Int16(MediaKeyConstants.systemDefinedEventSubtype)
        else { return nil }

        let data1 = nsEvent.data1

        // Extract key code from bits 16-31
        let keyCode = Int32((data1 & 0xFFFF0000) >> 16)
        // Extract key flags from bits 0-15
        let keyFlags = data1 & 0x0000FFFF
        // Bit 8-11: key state (0x0A = key down, 0x0B = key up)
        let isDown = (keyFlags & 0xFF00) >> 8 == 0x0A
        let isUp = (keyFlags & 0xFF00) >> 8 == 0x0B
        // Bit 0: repeat flag
        let isRepeat = (keyFlags & 0x1) != 0

        guard let keyType = keyTypeFrom(code: keyCode) else { return nil }
        guard isDown || isUp else { return nil }

        return MediaKeyEvent(
            keyType: keyType,
            keyState: isDown ? .keyDown : .keyUp,
            isRepeat: isRepeat
        )
    }

    private static func keyTypeFrom(code: Int32) -> KeyType? {
        switch code {
        case NXKeyType.play: return .play
        case NXKeyType.next: return .next
        case NXKeyType.previous: return .previous
        case NXKeyType.soundUp: return .soundUp
        case NXKeyType.soundDown: return .soundDown
        default: return nil
        }
    }
}
