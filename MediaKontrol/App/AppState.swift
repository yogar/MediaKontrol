import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    var currentVolume: Int = 50
    var volumeStep: Int = MediaKeyConstants.defaultVolumeStep
    var isIntercepting: Bool = false
    var activeDestinationId: String?
    var availableDestinations: [DestinationInfo] = []
    var currentTrack: TrackInfo?
    var lastError: String?
    var hasAccessibilityPermission: Bool = false
    let volumeHUD = VolumeHUDController()

    private var interceptor: MediaKeyInterceptor?
    private var router: MediaCommandRouter?
    private let registry = DestinationRegistry()
    private var pollingTask: Task<Void, Never>?
    private var didSetUp = false

    struct DestinationInfo: Identifiable {
        let id: String
        let name: String
        let iconName: String
        let isAvailable: Bool
    }

    func setup() async {
        guard !didSetUp else { return }
        didSetUp = true

        // Check accessibility permission
        hasAccessibilityPermission = AccessibilityPermission.requestIfNeeded()

        // Register destinations
        let spotify = SpotifyDestination()
        await registry.register(spotify)
        activeDestinationId = await registry.activeDestinationId

        // Create router
        let router = MediaCommandRouter(registry: registry, appState: self)
        self.router = router

        // Start interceptor if we have permission
        if hasAccessibilityPermission {
            startInterception(router: router)
        }

        // Initial volume fetch
        await refreshVolume()
        await refreshTrackInfo()

        // Start polling for destination availability
        startAvailabilityPolling()
    }

    private func startInterception(router: MediaCommandRouter) {
        let interceptor = MediaKeyInterceptor { [router] event in
            Task { await router.handle(event) }
        }

        if interceptor.start() {
            self.interceptor = interceptor
            isIntercepting = true
        } else {
            lastError = "Failed to create event tap. Check accessibility permissions."
            isIntercepting = false
        }
    }

    func toggleInterception() {
        if isIntercepting {
            interceptor?.stop()
            isIntercepting = false
        } else if let router {
            startInterception(router: router)
        }
    }

    func selectDestination(id: String) async {
        await registry.setActive(id: id)
        activeDestinationId = id
        await refreshVolume()
        await refreshTrackInfo()
    }

    func recheckPermission() {
        hasAccessibilityPermission = AccessibilityPermission.isTrusted
        if hasAccessibilityPermission && !isIntercepting, let router {
            startInterception(router: router)
        }
    }

    func refreshVolume() async {
        guard let destination = await registry.activeDestination else { return }
        if let volume = try? await destination.getVolume() {
            currentVolume = volume
        }
    }

    func refreshTrackInfo() async {
        guard let destination = await registry.activeDestination else { return }
        currentTrack = try? await destination.currentTrack()
    }

    // Called from MediaCommandRouter
    nonisolated func setVolume(_ volume: Int) async {
        await MainActor.run {
            self.currentVolume = volume
            self.volumeHUD.show(volume: volume)
        }
    }

    nonisolated func setTrack(_ track: TrackInfo?) async {
        await MainActor.run { self.currentTrack = track }
    }

    nonisolated func setError(_ message: String) async {
        await MainActor.run { self.lastError = message }
    }

    nonisolated func clearError() async {
        await MainActor.run { self.lastError = nil }
    }

    private func startAvailabilityPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                let destinations = await registry.allDestinations
                var infos: [DestinationInfo] = []
                for dest in destinations {
                    let available = await dest.isAvailable()
                    infos.append(DestinationInfo(
                        id: dest.id,
                        name: dest.name,
                        iconName: dest.iconName,
                        isAvailable: available
                    ))
                }
                self.availableDestinations = infos
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }
}
