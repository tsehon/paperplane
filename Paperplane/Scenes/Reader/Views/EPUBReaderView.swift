//
//  ReadiumWrapper.swift
//  Paperplane
//
//  Created by tyler on 2/19/24.
//

import SwiftUI
import UIKit
import R2Shared
import R2Streamer
import R2Navigator

struct EPUBReaderView: UIViewControllerRepresentable {
    var url: URL
    @Binding var preferences: EPUBPreferences
    @Binding var navigator: EPUBNavigatorViewController?
    @Binding var publication: Publication?
    @Binding var locator: Locator?
    
    var editingActions: [EditingAction] = [
   //     EditingAction(title: "Highlight", action: #selector(highlight:))
    ]

    func makeUIViewController(context: Context) -> UIViewController {
        print("making new view controller")
        // Initialize and return the EPUB reader view controller
        return EPUBReaderViewController(epubURL: url, coordinator: context.coordinator)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Cast the generic UIViewController to EPUBReaderViewController
        guard let epubReaderVC = uiViewController as? EPUBReaderViewController else { return }

        // Update the EPUB URL if it has changed
        if epubReaderVC.epubURL != url {
            epubReaderVC.epubURL = url
            epubReaderVC.setupNavigator()
            epubReaderVC.navigator?.submitPreferences(preferences)
            navigator = epubReaderVC.navigator
            publication = epubReaderVC.publication
        }
        
        if let loc = locator {
            navigator?.go(to: loc)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: EPUBReaderView

        init(_ parent: EPUBReaderView) {
            self.parent = parent
        }
        
        func updatePublication(_ publication: Publication?) {
            parent.publication = publication
        }

        func updateNavigator(_ navigator: EPUBNavigatorViewController?) {
            parent.navigator = navigator
        }
    }
}
