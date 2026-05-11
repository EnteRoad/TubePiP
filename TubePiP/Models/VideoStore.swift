import Foundation
import Combine

class VideoStore: ObservableObject {
    @Published private(set) var entries: [VideoEntry] = []

    private let storageKey = "tubepip_entries"
    private let maxHistoryCount = 200

    init() {
        load()
    }

    var history: [VideoEntry] {
        entries
            .filter { !$0.isBookmarked }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var bookmarks: [VideoEntry] {
        entries
            .filter { $0.isBookmarked }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func addEntry(url: String, title: String) {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        if let idx = entries.firstIndex(where: { $0.url == url && $0.timestamp > fiveMinutesAgo }) {
            entries[idx].timestamp = Date()
            entries[idx].title = title
        } else {
            entries.insert(VideoEntry(url: url, title: title), at: 0)
            if entries.filter({ !$0.isBookmarked }).count > maxHistoryCount {
                trimHistory()
            }
        }
        save()
    }

    func toggleBookmark(_ entry: VideoEntry) {
        guard let idx = entries.firstIndex(of: entry) else { return }
        entries[idx].isBookmarked.toggle()
        save()
    }

    func deleteEntries(_ offsets: IndexSet, from list: [VideoEntry]) {
        let idsToDelete = Set(offsets.map { list[$0].id })
        entries.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([VideoEntry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func trimHistory() {
        let bookmarked = entries.filter { $0.isBookmarked }
        let recent = entries
            .filter { !$0.isBookmarked }
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(maxHistoryCount)
        entries = bookmarked + Array(recent)
    }
}
