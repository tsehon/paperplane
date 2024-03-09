//
//  ReaderScene.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI

struct ReaderScene: Scene {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let aspectRatio: CGFloat = 1.3
    let width: CGFloat = 700
    
    var body: some Scene {
        WindowGroup(id: "reader", for: ReaderParams.self) { $params in
            ReaderView(params: $params).onAppear {
                BookService.shared.activeBook = params?.id
                // update user book data
                
            }
        }.windowResizability(.contentMinSize)
            .defaultSize(width: self.width, height: self.aspectRatio * self.width)
            .windowStyle(.plain)
    }
}
