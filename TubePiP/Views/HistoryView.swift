import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: VideoStore
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
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

                if store.history.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("尚無紀錄")
                            .font(.headline)
                        Text("觀看的影片會顯示在這裡")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("歷史紀錄")
        }
    }
}
