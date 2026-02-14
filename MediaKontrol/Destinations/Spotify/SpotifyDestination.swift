import Foundation

struct SpotifyDestination: MediaDestination {
    let id = BundleID.spotify
    let name = "Spotify"
    let iconName = "music.note"
    let capabilities: MediaCapability = .all

    private let runner = AppleScriptRunner()

    func isAvailable() async -> Bool {
        do {
            let result = try await runner.run(
                #"tell application "System Events" to (name of processes) contains "Spotify""#
            )
            return result == "true"
        } catch {
            return false
        }
    }

    func getVolume() async throws -> Int? {
        let result = try await runner.run(
            #"tell application "Spotify" to get sound volume"#
        )
        return Int(result)
    }

    func setVolume(_ level: Int) async throws {
        let clamped = max(MediaKeyConstants.volumeMin, min(MediaKeyConstants.volumeMax, level))
        try await runner.run(
            #"tell application "Spotify" to set sound volume to \#(clamped)"#
        )
    }

    @discardableResult
    func adjustVolume(by delta: Int) async throws -> Int {
        let script = """
        tell application "Spotify"
            set v to (sound volume) + (\(delta))
            if v > \(MediaKeyConstants.volumeMax) then set v to \(MediaKeyConstants.volumeMax)
            if v < \(MediaKeyConstants.volumeMin) then set v to \(MediaKeyConstants.volumeMin)
            set sound volume to v
            return v
        end tell
        """
        let result = try await runner.run(script)
        return Int(result) ?? 50
    }

    func playPause() async throws {
        try await runner.run(
            #"tell application "Spotify" to playpause"#
        )
    }

    func nextTrack() async throws {
        try await runner.run(
            #"tell application "Spotify" to next track"#
        )
    }

    func previousTrack() async throws {
        try await runner.run(
            #"tell application "Spotify" to previous track"#
        )
    }

    func currentTrack() async throws -> TrackInfo? {
        let script = """
        tell application "Spotify"
            if player state is not stopped then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                return trackName & "||" & trackArtist & "||" & trackAlbum
            else
                return ""
            end if
        end tell
        """
        let result = try await runner.run(script)
        guard !result.isEmpty else { return nil }

        let parts = result.components(separatedBy: "||")
        guard parts.count == 3 else { return nil }

        return TrackInfo(title: parts[0], artist: parts[1], album: parts[2])
    }
}
