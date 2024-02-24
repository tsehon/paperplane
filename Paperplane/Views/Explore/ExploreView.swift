//
//  ExploreView.swift
//  Paperplane
//
//  Created by tyler on 2/22/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ExploreView: View {
    @State private var books: [Book] = []
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var tagToBooks: [String: [Book]] = [:]
    @State private var tagsSorted: [String] = []
    @State private var searchText: String = ""
    @State private var isFilterSheetShown: Bool = false
    
    @State private var searchResults: [Book] = []
    @State private var filterTags: Set<String> = []

    func organizeAndSortBooks(loadedBooks: [Book]) {
        print("loaded books")
        
        if books.isEmpty {
            books = loadedBooks
            searchResults = loadedBooks
        }
        
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
    
    func filterSearchResults() {
        print("creating new result set")
        if searchText == "" && filterTags.isEmpty {
            searchResults = books
            return
        }
        
        print("filtering on: ", searchText.lowercased())
        print("and: ", filterTags)
        
        var res: [Book] = []
        for book in books {
            let hasCommonTags = book.tags.contains(where: filterTags.contains)
            let containsSearchTerm = searchText == "" || book.title.lowercased().contains(searchText.lowercased())
            
            if containsSearchTerm && hasCommonTags {
                res.append(book)
            }
        }
        
        searchResults = res
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Filters") {
                    isFilterSheetShown = true
                }
                TextField("Search Books", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 25)
                    .onChange(of: self.searchText) {
                        print("search text modified")
                        filterSearchResults()
                    }
            }
            ScrollView {
                ForEach(searchResults, id: \.id) { book in
                    HStack {
                        BookRowDetail(book: book)
                        Spacer()
                    }
                    .frame(alignment: .leading)
                    .padding(.vertical, 15)
                }
            }
        }
        .sheet(isPresented: $isFilterSheetShown) {
            FilterView(tags: $tagsSorted, selectedTags: $filterTags, sheetVisible: $isFilterSheetShown)
                .onChange(of: filterTags) {
                    print("filters modified")
                    filterSearchResults()
                }
        }
        .onAppear(perform: {
            BookService.shared.loadBookMetadata { loadedBooks in
                organizeAndSortBooks(loadedBooks: loadedBooks)
            }
        })
        .padding(50)
        .glassBackgroundEffect()
    }
}

struct ExplorePreview_Previews : PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
