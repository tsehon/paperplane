//
//  ReaderView.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI

struct ReaderView: View {
    @Binding var id: Book.ID?
    @Binding var isImmersive: Bool
    
    func toggleImmersion() {
        self.isImmersive.toggle()
        print("Immersion toggled: \(isImmersive)")
    }
    
    var body: some View {
        NavigationSplitView (columnVisibility: .constant(.detailOnly)) {
            EmptyView()
        } detail: {
            VStack {
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
                Text("Reading \(id ?? "NO BOOK")")
            }
            .frame(maxWidth: 200, maxHeight: 200)
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    HStack {
                        Button(action: toggleImmersion) {
                            HStack {
                                Text(isImmersive ? "De-Immerse" : "Immerse")
                                Label("Immerse", systemImage: isImmersive ? "sparkles.tv" : "sparkles.tv.fill")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ReaderViewPreviewContainer : View {
    @State private var bookId: Book.ID? = "Example ID"
    @State private var isImmersive: Bool = true
    
    var body: some View {
        ReaderView(id: $bookId, isImmersive: $isImmersive)
    }
}

struct ReaderPreview_Previews : PreviewProvider {
    static var previews: some View {
        ReaderViewPreviewContainer()
    }
}
