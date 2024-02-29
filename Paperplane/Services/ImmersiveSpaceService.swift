//
//  ImmersiveSpaceService.swift
//  Paperplane
//
//  Created by tyler on 2/27/24.
//

import Foundation
import SwiftUI
import RealityKit
import AVKit
import AVFoundation

class ImmersiveSpaceService: ObservableObject {
    static let shared = ImmersiveSpaceService() // Singleton instance
    
    @Published var environments: [ImmersiveEnvironment] = []
    @Published var skybox: ModelEntity? = nil
    @Published var prevSkybox: ModelEntity? = nil
    @Published var currentEnvId: ImmersiveEnvironment.ID = "none"
    @Published var isOpen: Bool = false

    @State private var player: AVPlayer = AVPlayer()

    private init() {}
    
    func setup() {
        loadEnvironments { loaded in
            self.environments = loaded
        }
    }
    
    func updateEnv(_ id: ImmersiveEnvironment.ID) {
        if currentEnvId == id {
            return
        }
        
        currentEnvId = id

        // close immersive space
        if id == "none" {
            player.pause()
            isOpen = false
            return
        }
        
        createSkybox(id: id)
    }

    func loadEnvironments(completion: @escaping ([ImmersiveEnvironment]) -> Void) {
        guard let url = URL(string: "\(API_URL)/environment/metadata") else {
            print("\(#file) \(#function): Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let environments = try? JSONDecoder().decode([ImmersiveEnvironment].self, from: data) {
                    DispatchQueue.main.async {
                        completion(environments)
                    }
                } else {
                    print("\(#file) \(#function) JSON Decoding Failed")
                }
            } else if let error = error {
                print("\(#file) \(#function) HTTP Request Failed \(error)")
            }
        }.resume()
    }
    
    // TODO: func generateEnvironment() ...
    
    func createSkybox(id: ImmersiveEnvironment.ID) {
        // partially visible when radius <= 0.5, but is obstructed??
        let skyBoxMesh = MeshResource.generateSphere(radius: 1000)

        StorageService.shared.fetchPreSignedURL(key: id) { [weak self] signedURL in
            guard let signedURL = signedURL else {
                print("Failed to fetch signed URL")
                return
            }
            
            DispatchQueue.main.async {
                let item = AVPlayerItem(url: signedURL)
                
                if let player = self?.player {
                    player.replaceCurrentItem(with: item)
                    let videoMaterial = VideoMaterial(avPlayer: player)
                    
                    let skyBoxEntity = ModelEntity(
                        mesh: skyBoxMesh,
                        materials: [videoMaterial]
                    )
                    
                    skyBoxEntity.name = id
                    skyBoxEntity.scale *= .init(x: 1, y: 1, z: -1)
                    skyBoxEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0)
                    skyBoxEntity.transform.rotation *= simd_quatf(angle: 1.6, axis: SIMD3<Float>(0,1,0))
                    
                    // loop video
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                        player.seek(to: .zero) // Rewind video to the start
                        player.play() // Play the video again
                    }
                    
                    self?.prevSkybox = self?.skybox
                    self?.skybox = skyBoxEntity
                    self?.isOpen = true
                    
                    player.play()
                }
            }
        }
    }

    func downloadVideo(from url: URL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let downloadTask = session.downloadTask(with: url) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    let documentsURL = try FileManager.default.url(for: .documentDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create: false)
                    let savedURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                    try FileManager.default.moveItem(at: tempLocalUrl, to: savedURL)
                    
                    // Use savedURL where the video file is saved
                    print("video saved to: ", savedURL)
                } catch {
                    print("Could not move file: \(error)")
                }
            } else {
                print("Error took place: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        downloadTask.resume()
    }
}

struct ImmersiveEnvironment: Identifiable, Decodable {
    var id: String
    var title: String
}
