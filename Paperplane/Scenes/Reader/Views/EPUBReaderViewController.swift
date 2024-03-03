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

class EPUBReaderViewController: UIViewController, EPUBNavigatorDelegate {
    var epubURL: URL
    var navigator: EPUBNavigatorViewController?
    var publication: Publication?
    var config: EPUBNavigatorViewController.Configuration

    weak var coordinator: ReadiumCoordinator?
        
    private var editingActions: [EditingAction] = /* EditingAction.defaultActions + */ [
        //EditingAction(title: "Highlight", action: #selector(highlight:))
        EditingAction(title: "Information", action: #selector(openInfo))
    ]

    init(epubURL: URL, config: EPUBNavigatorViewController.Configuration, coordinator: ReadiumCoordinator) {
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
                httpServer: GCDHTTPServer.shared,
                coordinator: coordinator
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
            navigator.delegate = self
            
            self.coordinator?.updateNavigator(navigator)
        } catch {
            print("Navigator Failed to initialize")
        }
    }
    
    func navigator(_ navigator: Navigator, locationDidChange locator: Locator) {
        // save locator epubNavigator.coordinator?.updateLocator(locator)
        /*
        if let epubNavigator = navigator as? EPUBNavigatorViewController {
        }
         */
        let positionLabel = {
            if let position = locator.locations.position, let pub = self.publication {
                return "\(position) of \(pub.positions.count)"
            } else if let progression = locator.locations.totalProgression {
                return "\(progression)%"
            } else {
                return ""
            }
        }()
        
        self.coordinator?.updatePositionLabel(positionLabel)
    }

    func navigator(_ navigator: VisualNavigator, didTapAt point: CGPoint) {
        // Turn pages when tapping the edge of the screen.
        guard !DirectionalNavigationAdapter(navigator: navigator).didTap(at: point) else {
            return
        }
        /*
        // clear a current search highlight
        if let decorator = self.navigator as? DecorableNavigator {
            decorator.apply(decorations: [], in: "search")
        }
         */
    }

    func navigator(_ navigator: VisualNavigator, didPressKey event: KeyEvent) {
        // Turn pages when pressing the arrow keys.
        DirectionalNavigationAdapter(navigator: navigator).didPressKey(event: event)
    }
    
    @objc func openInfo() {
        // present info sheet
        coordinator?.updateInfoVisible(true)
        // use navigator?.currentSelection
    }
}
