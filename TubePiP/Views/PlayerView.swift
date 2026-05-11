import SwiftUI

struct PlayerView: View {
    @Binding var pendingURL: String
    @EnvironmentObject var store: VideoStore

    @State private var urlInput: String = ""
    @State private var loadedURL: String = ""
    @State private var videoTitle: String = ""
    @State private var triggerPiP: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("YouTube URL 或搜尋...", text: $urlInput)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .onSubmit { loadURL() }

                Button("Go") { loadURL() }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            ZStack(alignment: .bottomTrailing) {
                YouTubeWebView(
                    urlString: $loadedURL,
                    videoTitle: $videoTitle,
                    triggerPiP: $triggerPiP
                )
                .ignoresSafeArea(edges: .bottom)

                if !loadedURL.isEmpty {
                    Button {
                        triggerPiP = true
                    } label: {
                        Image(systemName: "pip.enter")
                            .font(.title2)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: pendingURL) { url in
            guard !url.isEmpty else { return }
            urlInput = url
            loadedURL = url
            pendingURL = ""
        }
        .onChange(of: videoTitle) { title in
            guard !loadedURL.isEmpty, !title.isEmpty else { return }
            store.addEntry(url: loadedURL, title: title)
        }
    }

    private func loadURL() {
        let raw = urlInput.trimmingCharacters(in: .whitespaces)
        guard !raw.isEmpty else { return }

        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            loadedURL = normalizeYouTubeURL(raw)
        } else if raw.contains("youtube.com") || raw.contains("youtu.be") {
            loadedURL = normalizeYouTubeURL("https://\(raw)")
        } else {
            let encoded = raw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? raw
            loadedURL = "https://m.youtube.com/results?search_query=\(encoded)"
        }
    }

    private func normalizeYouTubeURL(_ url: String) -> String {
        var result = url
            .replacingOccurrences(of: "www.youtube.com", with: "m.youtube.com")
            .replacingOccurrences(of: "youtu.be/", with: "m.youtube.com/watch?v=")
        if !result.contains("m.youtube.com") {
            result = result.replacingOccurrences(of: "youtube.com", with: "m.youtube.com")
        }
        return result
    }
}
