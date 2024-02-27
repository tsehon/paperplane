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
    var navigator: EPUBNavigatorViewController?
    var publication: Publication?
    var config: EPUBNavigatorViewController.Configuration

    weak var coordinator: EPUBReaderView.Coordinator?
        
    private var editingActions: [EditingAction] = /* EditingAction.defaultActions + */ [
        //EditingAction(title: "Highlight", action: #selector(highlight:))
        EditingAction(title: "Information", action: #selector(openInfo))
    ]

    init(epubURL: URL, config: EPUBNavigatorViewController.Configuration, coordinator: EPUBReaderView.Coordinator) {
        self.epubURL = epubURL
        self.config = config
        self.coordinator = coordinator
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
                self?.coordinator?.updatePublication(publication)
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
        
        self.config.editingActions = editingActions
        
        // Pass the publication and server to the navigator
        do {
            let navigator = try EPUBNavigatorViewController(publication: publication,
                initialLocation: nil,
                config: self.config,
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
            
            navigator.view.contentMode = .scaleAspectFill
            
            self.coordinator?.updateNavigator(navigator)
        } catch {
            print("Navigator Failed to initialize")
        }
    }
    
    @objc func openInfo() {
        // present info sheet
        coordinator?.updateInfoVisible(true)
    }
}
