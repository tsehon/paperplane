//
//  ImmersiveReaderBuilder.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import SwiftUI
import AVKit
import AVFoundation
import RealityKit
import RealityKitContent

struct ImmersiveReaderView: View {
    @Binding var params: ReaderParams?
    
    var resourceId = "sampleVideo"
    
    private func createSkybox () -> Entity? {
        // partially visible when radius <= 0.5, but is obstructed??
        let skyBoxMesh = MeshResource.generateSphere(radius: 10)

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
        skyBoxEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0)
        
        player.isMuted = true
        player.play()
        return skyBoxEntity
    }
    
    var body: some View {
        ZStack {
            let _ = print("Updated ImmersiveReaderView")
            RealityView { content in
                guard let skybox = createSkybox() else { return }
                // Add the video to the main content.
                content.add(skybox)
            }
            EmptyView()
        }
    }
}

struct ImmersiveReaderViewPreviewContainer : View {
    @State private var params: ReaderParams? = ReaderParams(id: "example", url: Bundle.main.url(forResource: "example", withExtension: "epub")!)
    @State private var isImmersive: Bool = true
    
    var body: some View {
        ImmersiveReaderView(params: $params)
    }
}

struct ImmersiveReaderPreview_Previews : PreviewProvider {
    static var previews: some View {
        ImmersiveReaderViewPreviewContainer()
    }
}
