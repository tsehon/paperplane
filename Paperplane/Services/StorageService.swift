//
//  StorageService.swift
//  Paperplane
//
//  Created by tyler on 2/28/24.
//

import Foundation
import AWSClientRuntime
import AWSS3

class StorageService: ObservableObject {
    static let shared = StorageService() // Singleton instance
    
    private var client: S3Client?
    
    private init() {
        do {
            self.client = try S3Client(region: "us-west-1")
        } catch {
            dump(error, name: "Error accessing S3 service")
        }
    }
    
        
    func fetchPreSignedURL(key id: String, completion: @escaping (URL?) -> Void) {
        let urlString = "http://localhost:8080/environments/\(id)"
        guard let url = URL(string: urlString) else {
            print("\(#file) \(#function): Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching signed URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let signedURLString = json["url"] as? String,
                   let signedURL = URL(string: signedURLString) {
                    completion(signedURL)
                } else {
                    print("Could not parse JSON response")
                    completion(nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}
