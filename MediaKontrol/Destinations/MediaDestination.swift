struct TrackInfo: Sendable, Equatable {
    let title: String
    let artist: String
    let album: String
}

protocol MediaDestination: Sendable {
    var id: String { get }
    var name: String { get }
    var iconName: String { get }
    var capabilities: MediaCapability { get }

    func isAvailable() async -> Bool
    func getVolume() async throws -> Int?
    func setVolume(_ level: Int) async throws
    /// Adjusts volume by delta and returns the new volume level.
    func adjustVolume(by delta: Int) async throws -> Int
    func playPause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
    func currentTrack() async throws -> TrackInfo?
}
