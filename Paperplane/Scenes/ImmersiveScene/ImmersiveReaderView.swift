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
    
    var body: some View {
        ZStack {
            RealityView { content in
                if let initialSkybox = immersiveService.skybox {
                    content.add(initialSkybox)
                }
            } update: { content in
                // Clear existing content if needed
                if let prevSkybox = immersiveService.prevSkybox {
                    content.remove(prevSkybox)
                }
                
                // Add the new skybox
                if let updatedSkybox = immersiveService.skybox {
                    content.add(updatedSkybox)
                }
            }
        }
    }
}
