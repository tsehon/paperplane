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

public struct EPUBReaderView: UIViewControllerRepresentable {
    var url: URL
    var viewModel: NavigatorViewModel
    
    @Binding var preferences: EPUBPreferences
    @Binding var contextSheetVisible: Bool
    
    @State private var config: EPUBNavigatorViewController.Configuration = EPUBNavigatorViewController.Configuration()
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return EPUBReaderViewController(epubURL: url, config: config, coordinator: context.coordinator)
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
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
    
    public func makeCoordinator() -> ReadiumCoordinator {
        ReadiumCoordinator(self.viewModel)
    }
}

