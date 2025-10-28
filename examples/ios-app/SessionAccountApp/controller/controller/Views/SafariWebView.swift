//
//  SafariWebView.swift
//  Uses ASWebAuthenticationSession for proper WebAuthn support
//

import SwiftUI
import AuthenticationServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    let onComplete: () -> Void
    let onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> AuthViewController {
        let controller = AuthViewController(
            url: url,
            onComplete: onComplete,
            onError: onError
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AuthViewController, context: Context) {
        // No updates needed
    }
}

class AuthViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    let url: URL
    let onComplete: () -> Void
    let onError: (String) -> Void
    var session: ASWebAuthenticationSession?
    
    init(url: URL, onComplete: @escaping () -> Void, onError: @escaping (String) -> Void) {
        self.url = url
        self.onComplete = onComplete
        self.onError = onError
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAuthSession()
    }
    
    func startAuthSession() {
        // Use ASWebAuthenticationSession for proper WebAuthn/Passkeys support
        session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "sessionaccount"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin {
                    // User cancelled
                    self.onError("User cancelled")
                } else {
                    self.onError("Authentication failed: \(error.localizedDescription)")
                }
                return
            }
            
            if callbackURL != nil {
                // Success! Call completion handler
                // The parent view will handle dismissal through showWebView state
                self.onComplete()
            }
        }
        
        // IMPORTANT: Don't use ephemeral session so credentials can be saved
        session?.prefersEphemeralWebBrowserSession = false
        
        // Set presentation context provider
        session?.presentationContextProvider = self
        
        // Start the session
        if !(session?.start() ?? false) {
            onError("Failed to start authentication session")
        }
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? ASPresentationAnchor()
    }
}

#Preview {
    SafariWebView(
        url: URL(string: "https://x.cartridge.gg")!,
        onComplete: {},
        onError: { _ in }
    )
}

