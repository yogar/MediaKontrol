import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 12) {
            if !appState.hasAccessibilityPermission {
                accessibilityWarning
            }

            TrackInfoView(track: appState.currentTrack)

            VolumeIndicator(volume: appState.currentVolume)

            Divider()

            DestinationPicker(
                destinations: appState.availableDestinations,
                activeId: appState.activeDestinationId
            ) { id in
                Task { await appState.selectDestination(id: id) }
            }

            Divider()

            bottomControls
        }
        .padding(12)
        .frame(width: 260)
    }

    private var accessibilityWarning: some View {
        VStack(spacing: 6) {
            Label("Accessibility Access Required", systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
            Text("Grant access in System Settings > Privacy & Security > Accessibility")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Recheck Permission") {
                appState.recheckPermission()
            }
            .font(.caption)
        }
        .padding(8)
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var bottomControls: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { appState.isIntercepting },
                set: { _ in appState.toggleInterception() }
            )) {
                Text("Intercept")
                    .font(.caption)
            }
            .toggleStyle(.switch)
            .controlSize(.small)

            Spacer()

            if let error = appState.lastError {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                    .help(error)
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .font(.caption)
        }
    }
}
