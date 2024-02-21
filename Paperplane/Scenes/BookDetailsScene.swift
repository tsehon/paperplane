//
//  BookDetailsScene.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI

struct BookDetailsScene: Scene {
    var body: some Scene {
        WindowGroup("Book Details", id: "book-details", for: Book.ID.self) { $bookId in
            BookDetailView(id: $bookId)
        }
        .defaultSize(width: 400, height: 800)
    }
}
