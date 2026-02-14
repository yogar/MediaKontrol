import SwiftUI

struct VolumeHUDView: View {
    let volume: Int
    let isVisible: Bool

    private let hudSize: CGFloat = 200
    private let barHeight: CGFloat = 6

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: volumeIconName)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(.white)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(height: barHeight)

                    Capsule()
                        .fill(.white)
                        .frame(
                            width: max(barHeight, geo.size.width * CGFloat(volume) / 100.0),
                            height: barHeight
                        )
                }
            }
            .frame(height: barHeight)
            .padding(.horizontal, 24)
        }
        .padding(24)
        .frame(width: hudSize, height: hudSize)
        .background(.ultraThinMaterial.opacity(0.9))
        .background(Color.black.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.9)
        .animation(.easeInOut(duration: 0.2), value: isVisible)
        .animation(.easeInOut(duration: 0.15), value: volume)
    }

    private var volumeIconName: String {
        switch volume {
        case 0: "speaker.slash.fill"
        case 1...33: "speaker.wave.1.fill"
        case 34...66: "speaker.wave.2.fill"
        default: "speaker.wave.3.fill"
        }
    }
}

struct VolumeHUDContentWrapper: View {
    let controller: VolumeHUDController

    var body: some View {
        VolumeHUDView(
            volume: controller.currentVolume,
            isVisible: controller.isVisible
        )
    }
}
