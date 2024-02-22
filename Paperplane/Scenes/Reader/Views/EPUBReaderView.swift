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

    func makeUIViewController(context: Context) -> UIViewController {
        // Initialize and return the EPUB reader view controller
        return EPUBReaderViewController(epubURL: url)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Cast the generic UIViewController to EPUBReaderViewController
        guard let epubReaderVC = uiViewController as? EPUBReaderViewController else { return }
        
        // Update the EPUB URL if it has changed
        if epubReaderVC.epubURL != url {
            epubReaderVC.epubURL = url
            epubReaderVC.setupNavigator()
        }
        
        epubReaderVC.navigator?.submitPreferences(preferences)
    }
}
