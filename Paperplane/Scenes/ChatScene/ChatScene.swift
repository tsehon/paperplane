//
//  ChatScene.swift
//  Paperplane
//
//  Created by tyler on 2/25/24.
//

import Foundation
import SwiftUI

struct ChatScene: Scene {
    let aspectRatio: CGFloat = 1.3
    let width: CGFloat = 700
    
    var body: some Scene {
        WindowGroup(id: "chat", for: Book.ID.self) { $id in
            ChatView(bookId: $id)
        }.windowResizability(.contentMinSize)
            .defaultSize(width: self.width, height: self.aspectRatio * self.width)
            .windowStyle(.plain)
    }
}
