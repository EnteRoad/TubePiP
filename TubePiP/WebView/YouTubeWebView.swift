import SwiftUI
import WebKit

struct YouTubeWebView: UIViewRepresentable {
    @Binding var urlString: String
    @Binding var videoTitle: String
    @Binding var triggerPiP: Bool

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(videoTitle: $videoTitle)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true

        if let scriptURL = Bundle.main.url(forResource: "pip_inject", withExtension: "js"),
           let source = try? String(contentsOf: scriptURL, encoding: .utf8) {
            let script = WKUserScript(
                source: source,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )
            config.userContentController.addUserScript(script)
        }
        config.userContentController.add(context.coordinator, name: "tubePiP")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if !urlString.isEmpty,
           let url = URL(string: urlString),
           webView.url?.absoluteString != urlString {
            var request = URLRequest(url: url)
            request.setValue(
                "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
                forHTTPHeaderField: "User-Agent"
            )
            webView.load(request)
        }

        if triggerPiP {
            webView.evaluateJavaScript("window.__tubePiP_requestPiP()") { _, _ in }
            DispatchQueue.main.async { self.triggerPiP = false }
        }
    }
}
