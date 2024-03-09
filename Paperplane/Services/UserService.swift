//
//  UserService.swift
//  Paperplane
//
//  Created by tyler on 3/9/24.
//

import Foundation
import SwiftUI
import Combine

struct User: Identifiable, Decodable {
    var id: String
    var displayName: String
    var email: String
    var emailVerified: Bool
    var bio: String
    var preferences: [String: Any] // json
}

class UserService: ObservableObject {
    static let shared = UserService() // Singleton instance
    private var cancellables = Set<AnyCancellable>()
    
    @Published var user: User?
    @Published var emailVerified: Bool = false

    private init() {}
    
    func fetchUser(userId: User.ID) {
        
    }
    
    @MainActor
    func signInUser(id: User.ID) async -> Bool {
        guard let url = URL(string: "\(API_URL)/users/\(id)") else {
            print("Invalid URL")
            return false
        }
        
        // get user data
        do {
            let (getData, getResponse) = try await URLSession.shared.data(from: url)
            guard let httpResponse = getResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.badResponse
            }
            
            // update user's lastLogin
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
            
            let (updateData, updateResponse) = try await URLSession.shared.data(for: request)
            guard let httpResponse = updateResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let apiResponse = try? JSONDecoder().decode(ApiResponse.self, from: updateData) {
                    print("Error message: \(apiResponse.error ?? "Unknown error")")
                } else {
                    print("Failed to update user lastLogin. Unknown response format.")
                }
                return false
            }
            
            print("Successfully updated user lastLogin")
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func signUpUser(id: User.ID, name: String?, email: String) async -> Bool {
        guard let url = URL(string: "\(API_URL)/users/\(id)") else {
            print("Invalid URL")
            return false
        }
        
        let userPayload = [
            "userId": id,
            "displayName": name ?? email,
            "email": email,
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userPayload)
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("New user data synced with backend")
                return true
            } else {
                print("Failed to sync user data to backend")
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
}
