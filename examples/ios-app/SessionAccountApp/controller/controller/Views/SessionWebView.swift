//
//  SessionWebView.swift
//  WebView for session authorization with WebAuthn support
//

import SwiftUI
import WebKit
import AuthenticationServices

struct SessionWebView: View {
    let url: URL
    let onComplete: () -> Void
    let onError: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WebView(url: url, onComplete: onComplete, onError: onError)
                .navigationTitle("Authorize Session")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let onComplete: () -> Void
    let onError: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // CRITICAL: Enable JavaScript and allow it to open windows
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Enable inline media playback
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // IMPORTANT: Configure webpage preferences for WebAuthn
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        // Enable process pool sharing for better authentication
        configuration.processPool = WKProcessPool()
        
        // Create the web view
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // CRITICAL: Use a real Safari user agent for WebAuthn compatibility
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        // Enable inspection for debugging (remove in production)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        // Allow fullscreen elements
        if #available(iOS 15.0, *) {
            configuration.preferences.isElementFullscreenEnabled = true
        }
        
        // Load the URL
        var request = URLRequest(url: url)
        // Set proper headers for cross-origin requests
        request.setValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("navigate", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("document", forHTTPHeaderField: "Sec-Fetch-Dest")
        
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // Handle navigation
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Check if this is the callback URL
                if url.scheme == "sessionaccount" {
                    // Session was created
                    parent.onComplete()
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
        
        // Handle errors
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError("Failed to load: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onError("Failed to load: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SessionWebView(
        url: URL(string: "https://x.cartridge.gg")!,
        onComplete: {},
        onError: { _ in }
    )
}

