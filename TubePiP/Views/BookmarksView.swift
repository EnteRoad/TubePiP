import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var store: VideoStore
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(store.bookmarks) { entry in
                        VideoRowView(entry: entry)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(entry.url) }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.toggleBookmark(entry)
                                } label: {
                                    Label("移除書籤", systemImage: "bookmark.slash")
                                }
                            }
                    }
                    .onDelete { offsets in
                        store.deleteEntries(offsets, from: store.bookmarks)
                    }
                }

                if store.bookmarks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("尚無書籤")
                            .font(.headline)
                        Text("在歷史紀錄中向右滑動來新增書籤")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("書籤")
        }
    }
}
