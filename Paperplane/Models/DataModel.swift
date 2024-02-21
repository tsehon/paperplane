//
//  Book.swift
//  Paperplane
//
//  Created by tyler on 2/12/24.
//

import Foundation

struct Book: Identifiable, Decodable {
    var id: String
    var title: String
    var author: String
    var tags: [String]
    var rating: Float32
    var publisher: String
    var publishedDate: String
}

struct Tag: Identifiable, Decodable {
    var id = UUID()
    var name: String
    var books: [Book]
}
