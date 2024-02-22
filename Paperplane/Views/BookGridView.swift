//
//  BookGridView.swift
//  Paperplane
//
//  Created by tyler on 2/21/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct BookGridView: View {
    var tags: [String]
    var dict: [String: [Book]]
    private let gridItems = Array(repeating: GridItem(.flexible(), spacing: 20), count: 1)

    var body: some View {
        ScrollView {
            ForEach(tags, id: \.self) { tag in
                VStack(alignment: .leading) {
                    Text(tag)
                        .font(.title)
                        .padding([.top, .leading], 25.0)
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: gridItems, spacing: 20) {
                            ForEach(dict[tag] ?? [], id: \.id) { book in
                                BookItemView(book: book)
                            }
                        }
                        .padding(.horizontal, 50)
                    }
                }
            }
        }
    }
}

/*
 struct BookGridView_Previews : PreviewProvider {
 static var previews: some View {
 NavigationStack {
 BookGridView()
 }
 }
 }
 */
