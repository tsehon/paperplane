//
//  BookCoverView.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI

struct BookCoverView: View {
    let bookId: String
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Image(uiImage: imageLoader.image ?? UIImage(systemName: "book")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 150)
            .onAppear {
                if let url = URL(string: "http://localhost:8080/books/\(bookId)/cover") {
                    imageLoader.load(fromURL: url)
                }
            }
    }
}
