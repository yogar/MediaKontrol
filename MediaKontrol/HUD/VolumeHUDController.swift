import AppKit
import Observation
import SwiftUI

@Observable
@MainActor
final class VolumeHUDController {
    private(set) var currentVolume: Int = 50
    private(set) var isVisible: Bool = false

    private var panel: VolumeHUDPanel?
    private var dismissTask: Task<Void, Never>?

    private let dismissDelay: Duration = .seconds(1.5)

    func show(volume: Int) {
        currentVolume = volume

        if panel == nil {
            createPanel()
        }

        positionPanel()
        panel?.orderFrontRegardless()
        isVisible = true

        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: dismissDelay)
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    private func dismiss() {
        isVisible = false

        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            panel?.orderOut(nil)
        }
    }

    private func createPanel() {
        let hostView = NSHostingView(rootView: VolumeHUDContentWrapper(controller: self))
        hostView.setFrameSize(NSSize(width: 200, height: 200))

        let panel = VolumeHUDPanel(contentView: hostView)
        panel.setContentSize(NSSize(width: 200, height: 200))
        self.panel = panel
    }

    private func positionPanel() {
        guard let panel, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelSize = panel.frame.size

        let x = screenFrame.midX - panelSize.width / 2
        let y = screenFrame.origin.y + 140
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
