import WebKit
import SwiftUI

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    @Binding var videoTitle: String

    init(videoTitle: Binding<String>) {
        _videoTitle = videoTitle
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { result, _ in
            DispatchQueue.main.async {
                if let title = result as? String, !title.isEmpty {
                    self.videoTitle = title
                        .replacingOccurrences(of: " - YouTube", with: "")
                        .trimmingCharacters(in: .whitespaces)
                }
            }
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any] else { return }
        switch body["type"] as? String {
        case "title":
            if let title = body["value"] as? String, !title.isEmpty {
                DispatchQueue.main.async { self.videoTitle = title }
            }
        default:
            break
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }
}
