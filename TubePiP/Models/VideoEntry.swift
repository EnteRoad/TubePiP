import Foundation

struct VideoEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var url: String
    var title: String
    var thumbnail: String?
    var timestamp: Date
    var isBookmarked: Bool

    init(url: String, title: String) {
        self.id = UUID()
        self.url = url
        self.title = title.isEmpty ? url : title
        self.timestamp = Date()
        self.isBookmarked = false

        if let videoID = VideoEntry.extractVideoID(from: url) {
            self.thumbnail = "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg"
        }
    }

    static func extractVideoID(from url: String) -> String? {
        if let range = url.range(of: "youtu.be/") {
            let after = url[range.upperBound...]
            return String(after.prefix(while: { $0 != "?" && $0 != "&" && $0 != "/" }))
        }
        if let range = url.range(of: "[?&]v=", options: .regularExpression) {
            let after = url[range.upperBound...]
            return String(after.prefix(while: { $0 != "&" && $0 != "#" }))
        }
        if let range = url.range(of: "/shorts/") {
            let after = url[range.upperBound...]
            return String(after.prefix(while: { $0 != "?" && $0 != "/" }))
        }
        return nil
    }
}
