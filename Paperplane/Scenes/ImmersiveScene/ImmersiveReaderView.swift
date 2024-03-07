//
//  ImmersiveReaderBuilder.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct ImmersiveReaderView: View {
    @ObservedObject var immersiveService: ImmersiveSpaceService = ImmersiveSpaceService.shared
    @Environment(\.dismissImmersiveSpace) private var dismiss
    
    var body: some View {
        ZStack {
            RealityView { content in
                if let initialSkybox = immersiveService.skybox {
                    content.add(initialSkybox)
                }
            } update: { content in
                if immersiveService.currentEnvId == "none" {
                    Task {
                        await dismiss()
                    }
                }
                    
                print("updated immersiveReaderView")
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
