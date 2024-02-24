//
//  ChatView.swift
//  Paperplane
//
//  Created by tyler on 2/24/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ChatView: View {
    @Binding var sheetVisible: Bool
    
    var body: some View {
        VStack {
            Text("some text")
        }
        .padding(50)
        .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: .infinity)
        .glassBackgroundEffect()
    }
}

struct ChatViewPreviewContainer : View {
    var body: some View {
        ChatView(sheetVisible: .constant(true))
    }
}

struct ChatPreview_Previews : PreviewProvider {
    static var previews: some View {
        ChatViewPreviewContainer()
    }
}
