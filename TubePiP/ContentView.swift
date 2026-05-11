import SwiftUI

struct ContentView: View {
    @StateObject private var store = VideoStore()
    @State private var selectedTab = 0
    @State private var pendingURL: String = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            PlayerView(pendingURL: $pendingURL)
                .tabItem { Label("播放", systemImage: "play.rectangle.fill") }
                .tag(0)

            HistoryView(onSelect: { url in
                pendingURL = url
                selectedTab = 0
            })
            .tabItem { Label("歷史", systemImage: "clock.fill") }
            .tag(1)

            BookmarksView(onSelect: { url in
                pendingURL = url
                selectedTab = 0
            })
            .tabItem { Label("書籤", systemImage: "bookmark.fill") }
            .tag(2)
        }
        .environmentObject(store)
    }
}
