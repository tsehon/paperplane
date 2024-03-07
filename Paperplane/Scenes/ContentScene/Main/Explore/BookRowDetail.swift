//
//  BookRowDetail.swift
//  Paperplane
//
//  Created by tyler on 2/22/24.
//

import SwiftUI

struct BookRowDetail: View {
    @Environment(\.openWindow) private var openWindow
    
    var book: Book
    
    var body: some View {
        Button(action: {
            BookService.shared.downloadEPUBFile(bookId: book.id) { result in
                switch result {
                case .success(let fileURL):
                    let params = ReaderParams(id: book.id, url: fileURL)
                    if Thread.isMainThread {
                        openWindow(id: "reader", value: params)
                    } else {
                        DispatchQueue.main.sync {
                            openWindow(id: "reader", value: params)
                        }
                    }
                case .failure(let error):
                    print("Failed to download EPUB: \(error)")
                }
            }
        }) {
            HStack {
                BookCoverView(bookId: book.id, height: 75)
                VStack {
                    HStack {
                        Text(book.title)
                            .font(.title)
                            .foregroundColor(.primary)
                        Spacer()
                    }.frame(alignment: .leading)
                    HStack {
                        Text(book.author)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }.frame(alignment: .leading)
                }
                .padding([.top, .leading], 25.0)
                .lineLimit(1)
                .padding(.horizontal, 50)
            }
            .multilineTextAlignment(.leading)
            .background(Color(UIColor.systemBackground))
            .frame(alignment: .leading)
            .hoverEffect()
        }.buttonStyle(.plain)
    }
}
