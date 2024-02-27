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
    var viewModel: NavigatorViewModel
    
    @Binding var preferences: EPUBPreferences
    @Binding var contextSheetVisible: Bool
    
    @State private var config: EPUBNavigatorViewController.Configuration = EPUBNavigatorViewController.Configuration()
    
    func makeUIViewController(context: Context) -> UIViewController {
        return EPUBReaderViewController(epubURL: url, config: config, coordinator: context.coordinator)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Cast the generic UIViewController to EPUBReaderViewController
        guard let epubReaderVC = uiViewController as? EPUBReaderViewController else { return }

        // Update the EPUB URL if it has changed
        if epubReaderVC.epubURL != url {
            epubReaderVC.epubURL = url
            epubReaderVC.setupNavigator()
            epubReaderVC.navigator?.submitPreferences(preferences)
            viewModel.navigator = epubReaderVC.navigator
            viewModel.publication = epubReaderVC.publication
        }
        
        if let loc = viewModel.locator {
            viewModel.navigator?.go(to: loc)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.viewModel)
    }

    class Coordinator: NSObject {
        var viewModel: NavigatorViewModel

        init(_ viewModel: NavigatorViewModel) {
            self.viewModel = viewModel
        }
        
        func updatePublication(_ publication: Publication?) {
            viewModel.publication = publication
        }

        func updateNavigator(_ navigator: EPUBNavigatorViewController?) {
            viewModel.navigator = navigator
        }
        
        func updateLocator(_ locator: Locator?) {
            viewModel.locator = locator
        }
        
        func updateInfoVisible(_ isVisible: Bool) {
            viewModel.infoSheetVisible = true
        }
    }

}

