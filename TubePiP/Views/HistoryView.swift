import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: VideoStore
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(store.history) { entry in
                    VideoRowView(entry: entry)
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(entry.url) }
                        .swipeActions(edge: .leading) {
                            Button {
                                store.toggleBookmark(entry)
                            } label: {
                                Label("書籤", systemImage: "bookmark")
                            }
                            .tint(.yellow)
                        }
                }
                .onDelete { offsets in
                    store.deleteEntries(offsets, from: store.history)
                }
            }
            .navigationTitle("歷史紀錄")
            .overlay {
                if store.history.isEmpty {
                    ContentUnavailableView(
                        "尚無紀錄",
                        systemImage: "clock",
                        description: Text("觀看的影片會顯示在這裡")
                    )
                }
            }
        }
    }
}
