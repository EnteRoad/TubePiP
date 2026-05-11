import SwiftUI

struct VideoRowView: View {
    let entry: VideoEntry

    var body: some View {
        HStack(spacing: 12) {
            if let thumbStr = entry.thumbnail, let thumbURL = URL(string: thumbStr) {
                AsyncImage(url: thumbURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.25)
                }
                .frame(width: 80, height: 45)
                .cornerRadius(6)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 80, height: 45)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .lineLimit(2)
                    .font(.subheadline)
                Text(entry.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if entry.isBookmarked {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
