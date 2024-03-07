//
//  BookDetailView.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI

struct BookDetailView: View {
    @Binding var id: Book.ID?
    
    var body: some View {
        Text("Reading \(id ?? "NO BOOK")")
    }
}

struct BookDetailViewPreviewContainer : View {
     @State
    private var bookId: Book.ID? = "10101010110"

     var body: some View {
          BookDetailView(id: $bookId)
     }
}

struct BookDetailPreview_Previews : PreviewProvider {
    static var previews: some View {
        BookDetailViewPreviewContainer()
    }
}
