//
//  ImmersiveReaderBuilder.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI
import AVKit
import AVFoundation
import RealityKit
import RealityKitContent

struct ImmersiveReaderView: View {
    @Binding var id: Book.ID?
    @Binding var isImmersive: Bool
    
    var resourceId = "sampleVideo"
    
    private func createSkybox () -> Entity? {
        let skyBoxMesh = MeshResource.generateSphere(radius: 0.5)
        
        guard let url = Bundle.main.url(forResource: resourceId, withExtension: "mp4") else {
            fatalError("Video not found")
        }
        let player = AVPlayer(url: url)
        let videoMaterial = VideoMaterial(avPlayer: player)
        
        let skyBoxEntity = ModelEntity(
            mesh: skyBoxMesh,
            materials: [videoMaterial]
        )
        
        skyBoxEntity.scale *= .init(x: 1, y: 1, z: -1)
        skyBoxEntity.transform.translation += SIMD3<Float>(0.0, 0.0, 0)
        
        return skyBoxEntity
    }
    
    var body: some View {
        ZStack {
            let _ = print("Updated ImmersiveReaderView")
            if isImmersive == true {
                let _ = print("Immersive On")
                RealityView { content, attachments in
                    guard let skybox = createSkybox() else { return }
                    
                    // Add the video to the main content.
                    content.add(skybox)
                    
                    // Add the ReaderView as an attachment
                    if let reader = attachments.entity(for: "reader") {
                        reader.setPosition([0, 0, 0.25], relativeTo: skybox)
                        content.add(reader)
                    }
                } attachments: {
                    Attachment(id: "reader") {
                        ReaderView(id: $id, isImmersive: $isImmersive)
                            .zIndex(100)
                    }
                }
                ReaderView(id: $id, isImmersive: $isImmersive)
            } else {
                ReaderView(id: $id, isImmersive: $isImmersive)
            }
        }
    }
}

struct ImmersiveReaderViewPreviewContainer : View {
    @State private var bookId: Book.ID? = "Example ID"
    @State private var isImmersive: Bool = true
    
    var body: some View {
        ImmersiveReaderView(id: $bookId, isImmersive: $isImmersive)
    }
}

struct ImmersiveReaderPreview_Previews : PreviewProvider {
    static var previews: some View {
        ImmersiveReaderViewPreviewContainer()
    }
}
