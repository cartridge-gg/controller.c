//
//  InAppSafariView.swift
//  Uses SFSafariViewController for full WebAuthn support
//

import SwiftUI
import SafariServices

struct InAppSafariView: UIViewControllerRepresentable {
    let url: URL
    let onComplete: () -> Void
    let onError: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.delegate = context.coordinator
        safari.preferredBarTintColor = .systemBackground
        safari.preferredControlTintColor = .systemBlue
        safari.dismissButtonStyle = .close
        
        // Store reference for dismissal
        context.coordinator.safariViewController = safari
        
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: InAppSafariView
        weak var safariViewController: SFSafariViewController?
        
        init(parent: InAppSafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            // User manually dismissed the Safari view
            // Don't call onError here, just let it close naturally
        }
        
        func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
            // Check if this is the callback URL
            if URL.scheme == "sessionaccount" {
                // Dismiss Safari immediately
                controller.dismiss(animated: true) {
                    // Call completion after dismissal
                    self.parent.onComplete()
                }
            }
        }
        
        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            if !didLoadSuccessfully {
                parent.onError("Failed to load authentication page")
            }
        }
    }
}

#Preview {
    InAppSafariView(
        url: URL(string: "https://x.cartridge.gg")!,
        onComplete: {},
        onError: { _ in }
    )
}

