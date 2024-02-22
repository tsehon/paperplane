//
//  BookItem.swift
//  Paperplane
//
//  Created by tyler on 2/21/24.
//

import SwiftUI

struct BookItemView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var book: Book
    
    func openImmersiveReader(id: Book.ID, url: URL) async {
        let params = ReaderParams(id: id, url: url)
        await openImmersiveSpace(id: "immersive-reader", value: params)
    }
    
    var body: some View {
        Button(action: {
            Task {
                BookService.shared.downloadEPUBFile(bookId: book.id) { result in
                    switch result {
                    case .success(let fileURL):
                        print("Downloaded and saved Ebook to \(fileURL)")
                        print("Opening Reader")
                        Task {
                            await openImmersiveReader(id: book.id, url: fileURL)
                            dismissWindow(id: "home")
                        }
                    case .failure(let error):
                        print("Failed to download EPUB: \(error)")
                    }
                }
            }
        }) {
            VStack {
                BookCoverView(bookId: book.id)
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(width: 200, alignment: .center)
            .hoverEffect()
        }.buttonStyle(.plain)
    }
}

/*
 struct BookItemView_Previews : PreviewProvider {
 static var previews: some View {
 NavigationStack {
 BookItemView()
 }
 }
 }
 */
