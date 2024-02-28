//
//  ImmersiveReaderBuilder.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveReaderView: View {
    @ObservedObject var immersiveService: ImmersiveSpaceService = ImmersiveSpaceService.shared
    
    @State private var currSkybox: ModelEntity? = nil
    
    var body: some View {
        ZStack {
            RealityView { content in
                if let initialSkybox = immersiveService.skybox {
                    currSkybox = initialSkybox
                    content.add(initialSkybox)
                }
            } update: { content in
                // Clear existing content if needed
                if let curr = currSkybox {
                    content.remove(curr)
                }
                
                // Add the new skybox
                if let updatedSkybox = immersiveService.skybox {
                    content.add(updatedSkybox)
                    currSkybox = updatedSkybox
                }
            }
        }
    }
}

struct ImmersiveReaderViewPreviewContainer : View {
    var body: some View {
        ImmersiveReaderView()
    }
}

struct ImmersiveReaderPreview_Previews : PreviewProvider {
    static var previews: some View {
        ImmersiveReaderViewPreviewContainer()
    }
}
