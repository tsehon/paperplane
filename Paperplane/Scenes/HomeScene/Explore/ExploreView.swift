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
    @ObservedObject var bookService: BookService = BookService.shared
    
    @State private var searchText: String = ""
    @State private var filterTags: Set<String> = []
    @State private var isFilterSheetShown: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button("Filters") {
                    isFilterSheetShown = true
                }
                TextField("Search Books", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 25)
                    .onChange(of: searchText) {
                        bookService.updateSearchResults(searchText: searchText, filterTags: filterTags)
                    }
                    .onSubmit {
                        if searchText != "" {
                            bookService.updateSearchResults(searchText: searchText, filterTags: filterTags)
                        }
                    }
            }
            List {
                ForEach(bookService.searchResults, id: \.id) { book in
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
            FilterView(tags: bookService.tagsSorted, selectedTags: $filterTags, sheetVisible: $isFilterSheetShown)
                .onChange(of: filterTags) {
                    bookService.updateSearchResults(searchText: searchText, filterTags: filterTags)
                }
        }
        .padding(50)
        .glassBackgroundEffect()
    }
}

struct ExplorePreview_Previews : PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
