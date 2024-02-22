//
//  EPUBReaderViewController.swift
//  Paperplane
//
//  Created by tyler on 2/21/24.
//

import SwiftUI
import UIKit
import R2Shared
import R2Streamer
import R2Navigator
import ReadiumAdapterGCDWebServer

class EPUBReaderViewController: UIViewController {
    var epubURL: URL
    var publication: Publication?
    var navigator: EPUBNavigatorViewController?

    
    init(epubURL: URL) {
        self.epubURL = epubURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPublicationAndServer()
    }
    
    private func setupPublicationAndServer() {
        let streamer = Streamer()
        let asset = FileAsset(url: epubURL)
        
        streamer.open(asset: asset, allowUserInteraction: true) { [weak self] result in
            switch result {
            case .success(let publication):
                self?.publication = publication
                DispatchQueue.main.async {
                    self?.setupNavigator()
                }
            case .failure(let error):
                print("Failed to load EPUB: \(error)")
            default:
                return
            }
        }
    }
    
    func setupNavigator() {
        guard let publication = publication else {
            return
        }
        
        // Pass the publication and server to the navigator
        do {
            let navigator = try EPUBNavigatorViewController(publication: publication,
                initialLocation: nil,
                httpServer: GCDHTTPServer.shared
            )
            addChild(navigator)
            view.addSubview(navigator.view)
            
            navigator.didMove(toParent: self)
            navigator.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                navigator.view.topAnchor.constraint(equalTo: view.topAnchor),
                navigator.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigator.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigator.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        } catch {
            print("Navigator Failed to initialize")
        }
    }
}
