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
    @State private var bookId: Book.ID
    
    var epubURL: URL // URL of the EPUB file

    func makeUIViewController(context: Context) -> UIViewController {
        // Placeholder for the EPUB reader view controller
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}
