//
//  PaperplaneApp.swift
//  Paperplane
//
//  Created by tyler on 2/9/24.
//

import SwiftUI

@main
struct PaperplaneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 200, height: 200)
        
        BookDetailsScene()
        ReaderScene()
    }
}
