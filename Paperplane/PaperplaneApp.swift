//
//  PaperplaneApp.swift
//  Paperplane
//
//  Created by tyler on 2/9/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct ApiResponse: Codable {
    var error: String?
    var message: String?
}

let API_URL = "http://localhost:8080"

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        BookService.shared.setup()
        ImmersiveSpaceService.shared.setup()
        return true
    }
    
    /* google sign-in ******
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        return false
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error signing in with Google: \(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Use the AuthenticationManager to handle Firebase sign-in
        let authManager = AuthenticationManager()
        authManager.signInWithGoogle(credentials: credential)
    }
    */
}

@main
struct PaperplaneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup(id: "home") {
            ContentView()
                .environmentObject(authViewModel)
            /* google sign-in
                .onOpenURL { url in
                  GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
             */
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 800)
        
        ReaderScene()
            .environmentObject(authViewModel)
        BookDetailsScene()
        ImmersiveReaderScene()
        ChatScene()
    }
}
