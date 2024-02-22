//
//  ReaderScene.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI

struct ReaderScene: Scene {
    @State private var isImmersive: Bool = true
    @State private var style: ImmersionStyle = .progressive
    
    var body: some Scene {
#if os(visionOS)
        ImmersiveSpace(id: "immersive-reader", for: ReaderParams.self) { $params in
            ImmersiveReaderView(params: $params, isImmersive: $isImmersive)
        }.immersionStyle(selection: $style, in: .full)
#else
        WindowGroup("Reader", id: "reader", for: Book.ID.self) { $bookId in
            ReaderView(id: $bookId)
        }
        .defaultSize(width: 400, height: 800)
#endif
    }
}
