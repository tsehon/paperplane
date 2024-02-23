//
//  HomeView.swift
//  Paperplane
//
//  Created by tyler on 2/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HomeView: View {
    @State private var books: [Book] = []
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var tagToBooks: [String: [Book]] = [:]
    @State private var tagsSorted: [String] = []
    @State private var searchText: String = ""

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
    
    var body: some View {
        VStack {
            BookGridView(tags: tagsSorted, dict: tagToBooks)
        }
        .padding(20)
            .onAppear(perform: {
                BookService.shared.loadBookMetadata { loadedBooks in
                    organizeAndSortBooks(loadedBooks: loadedBooks)
                }
            })
            .frame(minWidth: 800, maxWidth: 2000, minHeight: 800, maxHeight: 1600)
    }
}

struct HomePreview_Previews : PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
