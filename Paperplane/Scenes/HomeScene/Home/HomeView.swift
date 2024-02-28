//
//  HomeView.swift
//  Paperplane
//
//  Created by tyler on 2/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HomeView: View {
    @ObservedObject var bookService: BookService = BookService.shared
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            BookGridView(tags: bookService.tagsSorted, dict: bookService.tagToBooks)
        }
        .padding(40)
        .glassBackgroundEffect()
    }
}

struct HomePreview_Previews : PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
