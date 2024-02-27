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
    
    @State var height: CGFloat
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Image(uiImage: imageLoader.image ?? UIImage(systemName: "book")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .onAppear {
                if let url = URL(string: "http://localhost:8080/book/\(bookId)/cover") {
                    imageLoader.load(fromURL: url)
                }
            }
    }
}
