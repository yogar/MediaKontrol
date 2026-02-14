import SwiftUI

struct DestinationPicker: View {
    let destinations: [AppState.DestinationInfo]
    let activeId: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Destination")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(destinations) { dest in
                Button {
                    onSelect(dest.id)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: dest.iconName)
                            .frame(width: 16)
                        Text(dest.name)
                        Spacer()
                        if dest.id == activeId {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                        Circle()
                            .fill(dest.isAvailable ? .green : .gray)
                            .frame(width: 8, height: 8)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(dest.id == activeId ? Color.accentColor.opacity(0.1) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
