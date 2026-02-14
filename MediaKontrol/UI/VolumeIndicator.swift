import SwiftUI

struct VolumeIndicator: View {
    let volume: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: volumeIcon)
                    .foregroundStyle(.secondary)
                Text("Volume")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(volume)%")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.quaternary)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(.tint)
                        .frame(width: geometry.size.width * CGFloat(volume) / 100.0, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private var volumeIcon: String {
        switch volume {
        case 0: "speaker.slash.fill"
        case 1...33: "speaker.wave.1.fill"
        case 34...66: "speaker.wave.2.fill"
        default: "speaker.wave.3.fill"
        }
    }
}
