//
//  ReaderScene.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI

struct ReaderScene: Scene {
    var body: some Scene {
        WindowGroup(id: "reader", for: ReaderParams.self) { $params in
            ReaderView(params: $params)
        }.windowResizability(.contentMinSize)
            .defaultSize(width: 1200, height: 1600)
    }
}
