//
//  ReadingView.swift
//  Paperplane
//
//  Created by tyler on 2/16/24.
//

import Foundation
import SwiftUI

struct ReadingView: View {
    var book: Book
    
    var body: some View {
        Text("Reading \(book.title) by \(book.author)")
    }
}
