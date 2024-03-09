//
//  AuthenticationService.swift
//  Paperplane
//
//  Created by tyler on 3/6/24.
//

import Combine
import SwiftUI
import FirebaseCore
import FirebaseAuth

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  @Published var confirmPassword = ""

  @Published var flow: AuthenticationFlow = .login

  @Published var isValid  = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage = ""
  @Published var user: User?
  @Published var displayName = ""

  init() {
    registerAuthStateHandler()

    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
          ? !(email.isEmpty || password.isEmpty)
          : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
      }
      .assign(to: &$isValid)
  }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.authenticationState = user == nil ? .unauthenticated : .authenticated
        self.displayName = user?.displayName ?? ""
      }
    }
  }

  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  private func wait() async {
    do {
      print("Wait")
      try await Task.sleep(nanoseconds: 1_000_000_000)
      print("Done")
    }
    catch {
      print(error.localizedDescription)
    }
  }

  func reset() {
    flow = .login
    email = ""
    password = ""
    confirmPassword = ""
  }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: self.email, password: self.password)
                
            guard let user = Auth.auth().currentUser else {
                print("Failed to retrieve current user")
                return false
            }
            
            guard let url = URL(string: "\(API_URL)/users/\(user.uid)") else {
                print("Invalid URL")
                return false
            }
            
            let dateFormatter = ISO8601DateFormatter()
            let lastLoginString = dateFormatter.string(from: Date.now)
            
            let userPayload = [
                "lastLogin": lastLoginString,
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: userPayload)
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let apiResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                    print("Error message: \(apiResponse.error ?? "Unknown error")")
                } else {
                    print("Failed to update user lastLogin. Unknown response format.")
                }
                authenticationState = .unauthenticated
                return false
            }
            
            print("Successfully updated user lastLogin")
            authenticationState = .authenticated
            return true
        }
        catch  {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do  {
            try await Auth.auth().createUser(withEmail: email, password: password)
            
            guard let user = Auth.auth().currentUser else {
                print("Failed to retrieve current user")
                return false
            }
            
            guard let url = URL(string: "\(API_URL)/users/\(user.uid)") else {
                print("Invalid URL")
                return false
            }
            
            let userPayload = [
                "userId": user.uid,
                "displayName": user.displayName ?? user.email,
                "email": user.email,
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: userPayload)
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("New user data synced with backend")
                authenticationState = .authenticated
                return true
            } else {
                print("Failed to sync user data to backend")
                authenticationState = .unauthenticated
                return false
            }
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            authenticationState = .unauthenticated
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            authenticationState = .unauthenticated
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
