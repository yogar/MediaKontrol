import Foundation

actor MediaCommandRouter {
    private let registry: DestinationRegistry
    private let appState: AppState

    init(registry: DestinationRegistry, appState: AppState) {
        self.registry = registry
        self.appState = appState
    }

    func handle(_ event: MediaKeyEvent) async {
        guard let command = mapToCommand(event) else { return }

        guard let destination = await registry.activeDestination else {
            await appState.setError("No active destination")
            return
        }

        do {
            switch command {
            case .volumeUp:
                let step = await appState.volumeStep
                let volume = try await destination.adjustVolume(by: step)
                await appState.setVolume(volume)

            case .volumeDown:
                let step = await appState.volumeStep
                let volume = try await destination.adjustVolume(by: -step)
                await appState.setVolume(volume)

            case .playPause:
                try await destination.playPause()
                await refreshTrackInfo(from: destination)

            case .nextTrack:
                try await destination.nextTrack()
                await refreshTrackInfo(from: destination)

            case .previousTrack:
                try await destination.previousTrack()
                await refreshTrackInfo(from: destination)
            }

            await appState.clearError()
        } catch {
            await appState.setError(error.localizedDescription)
        }
    }

    private func mapToCommand(_ event: MediaKeyEvent) -> MediaCommand? {
        switch event.keyType {
        case .play: return .playPause
        case .next: return .nextTrack
        case .previous: return .previousTrack
        case .soundUp: return .volumeUp
        case .soundDown: return .volumeDown
        }
    }

    private func refreshTrackInfo(from destination: any MediaDestination) async {
        // Small delay to let the player update its state
        try? await Task.sleep(for: .milliseconds(300))
        if let track = try? await destination.currentTrack() {
            await appState.setTrack(track)
        }
    }
}
