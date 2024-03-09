//
//  Queries.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI
import Combine
import R2Shared

struct Book: Identifiable, Decodable {
    var id: String
    var title: String
    var author: String
    var tags: [String]
    var rating: Float32
    var publisher: String
    var publishedDate: String
}

struct UserBook: Identifiable, Decodable {
    var id: String // bookId
    var readingStatus: String
    var liked: Bool
    var progress: Double
    var locator: Locator
    var lastRead: String
}

struct Tag: Identifiable, Decodable {
    var id = UUID()
    var name: String
}

class BookService: ObservableObject {
    static let shared = BookService() // Singleton instance
    private var cancellables = Set<AnyCancellable>()

    @Published var books: [Book.ID: Book] = [:]
    @Published var tagToBooks: [String: [Book]] = [:]
    @Published var tagsSorted: [String] = []
    @Published var searchResults: [Book] = []
    @Published var bookIdToImage: [Book.ID: UIImage] = [:]
    @Published var activeBook: Book.ID? = nil
    @Published var currentSelectedBook: Book.ID? = nil

    private init() {}
    
    func setup() {
        loadBooksMetadata { loaded in
            for book in loaded {
                self.books[book.id] = book
            }
            self.organizeAndSortBooks(loadedBooks: loaded)
            self.searchResults = loaded
            self.loadBookCovers()
        }
    }
    
    func updateSearchResults(searchText: String, filterTags: Set<String>) {
        if searchText.isEmpty && filterTags.isEmpty {
            searchResults = Array(self.books.values)
            return
        }
        
        var res: [Book] = []
        print(searchText.lowercased())
        for book in self.books.values {
            let hasCommonTags = filterTags.isEmpty || book.tags.contains(where: filterTags.contains)
            let containsSearchTerm = searchText.isEmpty || book.title.lowercased().contains(searchText.lowercased())
            print(book.title.lowercased())
            
            if containsSearchTerm && hasCommonTags {
                res.append(book)
            }
        }
        
        print(res.count)
        searchResults = res
    }
    
    func organizeAndSortBooks(loadedBooks: [Book]) {
        var newTagToBooks: [String: [Book]] = [:]

        for book in loadedBooks {
            for tag in book.tags {
                newTagToBooks[tag, default: []].append(book)
            }
        }
        
        let sortedTags = newTagToBooks.keys.sorted {
            (newTagToBooks[$0]?.count ?? 0) > (newTagToBooks[$1]?.count ?? 0)
        }
        
        DispatchQueue.main.async {
            self.tagToBooks = newTagToBooks
            self.tagsSorted = sortedTags
        }
    }
    
    func loadBookMetadata(id: Book.ID, completion: @escaping (Book) -> Void) {
        if let metadata = books[id] {
            completion(metadata)
        }
        
        guard let url = URL(string: "\(API_URL)/books/metadata/\(id)") else {
            print("\(#file) \(#function) loadBookMetadata: Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let book = try? JSONDecoder().decode(Book.self, from: data) {
                    DispatchQueue.main.async {
                        completion(book)
                    }
                } else {
                    print(data)
                    print("\(#file) \(#function) JSON Decoding Failed")
                }
            } else if let error = error {
                print("\(#file) \(#function) HTTP Request Failed \(error)")
            }
        }.resume()
    }

    func loadBooksMetadata(completion: @escaping ([Book]) -> Void) {
        guard let url = URL(string: "\(API_URL)/books/metadata") else {
            print("\(#file) \(#function): Invalid URL")
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
                    print(data)
                    print("\(#file) \(#function) JSON Decoding Failed")
                }
            } else if let error = error {
                print("\(#file) \(#function) HTTP Request Failed \(error)")
            }
        }.resume()
    }
    
    func loadBookCovers() {
        for book in books.values {
            loadBookCover(bookId: book.id)
        }
    }
    
    func loadBookCover(bookId: Book.ID) {
        if let _ = bookIdToImage[bookId] {
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/books/\(bookId)/cover") else {
            print("\(#file) \(#function): Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.bookIdToImage[bookId] = $0
            })
            .store(in: &cancellables)
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
