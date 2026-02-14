struct MediaCapability: OptionSet, Sendable {
    let rawValue: Int

    static let volume       = MediaCapability(rawValue: 1 << 0)
    static let playPause    = MediaCapability(rawValue: 1 << 1)
    static let nextTrack    = MediaCapability(rawValue: 1 << 2)
    static let previousTrack = MediaCapability(rawValue: 1 << 3)
    static let trackInfo    = MediaCapability(rawValue: 1 << 4)

    static let all: MediaCapability = [.volume, .playPause, .nextTrack, .previousTrack, .trackInfo]
}
