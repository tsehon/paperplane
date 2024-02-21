//
//  Queries.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation

let API_URL = "http://localhost:8080"

class BookService {
    static let shared = BookService() // Singleton instance

    func loadBookMetadata(completion: @escaping ([Book]) -> Void) {
        guard let url = URL(string: "\(API_URL)/books") else {
            print("[BookService] loadBookMetadata: Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let books = try? JSONDecoder().decode([Book].self, from: data) {
                    DispatchQueue.main.async {
                        completion(books)
                    }
                } else {
                    print("[BookService] JSON Decoding Failed")
                }
            } else if let error = error {
                print("[BookService] HTTP Request Failed \(error)")
            }
        }.resume()
    }
    
    func downloadEPUBFile(bookId: Book.ID, completion: @escaping (Result<URL, Error>) -> Void) {
        if fileExists(withId: bookId) {
            let fileManager = FileManager.default
            if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filePath = documentsPath.appendingPathComponent("\(bookId).epub")
                completion(.success(filePath))
                return
            }
        }
        
        guard let url = URL(string: "\(API_URL)/books/\(bookId)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let fileURL = try self.saveDataToFile(data: data, withId: bookId)
                completion(.success(fileURL))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    func saveDataToFile(data: Data, withId id: String) throws -> URL {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.fileDoesNotExist)
        }
        
        let filePath = documentsPath.appendingPathComponent("\(id).epub")
        try data.write(to: filePath)
        
        return filePath
    }
    
    func fileExists(withId id: String) -> Bool {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let filePath = documentsPath.appendingPathComponent("\(id).epub")
        return fileManager.fileExists(atPath: filePath.path)
    }
}
