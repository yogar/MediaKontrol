import SwiftUI

struct TrackInfoView: View {
    let track: TrackInfo?

    var body: some View {
        if let track {
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text("\(track.artist) — \(track.album)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("No track playing")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
