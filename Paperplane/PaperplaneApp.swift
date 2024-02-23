//
//  PaperplaneApp.swift
//  Paperplane
//
//  Created by tyler on 2/9/24.
//

import SwiftUI

@main
struct PaperplaneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup(id: "home") {
            ContentView()
        }
        .windowStyle(.plain)
        .defaultSize(width: 1000, height: 800)
        
        BookDetailsScene()
        ReaderScene()
        ImmersiveReaderScene()
    }
}
