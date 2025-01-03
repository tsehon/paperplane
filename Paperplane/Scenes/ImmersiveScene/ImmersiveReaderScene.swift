//
//  ImmersiveReaderScene.swift
//  Paperplane
//
//  Created by tyler on 2/22/24.
//

import Foundation
import SwiftUI

struct ImmersiveReaderScene: Scene {
    @State private var style: ImmersionStyle = .progressive
    
    var body: some Scene {
        ImmersiveSpace(id: "immersive-reader") {
            ImmersiveReaderView()
        }.immersionStyle(selection: $style, in: .full, .progressive, .mixed)
    }
}
