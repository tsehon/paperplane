//
//  BookCoverView.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI

struct BookCoverView: View {
    @ObservedObject var bookToImage: BookService = BookService.shared
    let bookId: String
    
    @State var height: CGFloat
    
    var body: some View {
        Image(uiImage: BookService.shared.bookIdToImage[bookId] ?? UIImage(systemName: "book")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
    }
}
