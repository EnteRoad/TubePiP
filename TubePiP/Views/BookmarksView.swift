import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var store: VideoStore
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
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
            .navigationTitle("書籤")
            .overlay {
                if store.bookmarks.isEmpty {
                    ContentUnavailableView(
                        "尚無書籤",
                        systemImage: "bookmark",
                        description: Text("在歷史紀錄中向右滑動來新增書籤")
                    )
                }
            }
        }
    }
}
