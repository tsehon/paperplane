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

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
