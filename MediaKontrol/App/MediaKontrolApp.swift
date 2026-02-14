import SwiftUI

@main
struct MediaKontrolApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
                .task { await appState.setup() }
        } label: {
            Image(systemName: "speaker.wave.2.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
