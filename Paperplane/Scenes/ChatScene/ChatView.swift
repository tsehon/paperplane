//
//  ChatView.swift
//  Paperplane
//
//  Created by tyler on 2/24/24.
//

import Foundation
import SwiftUI

struct ChatView: View {
    @Binding var bookId: Book.ID?
    @StateObject private var viewModel: ChatViewModel = ChatViewModel()
    @State private var prompt: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { scroll in
                ScrollView {
                    ForEach(viewModel.messages, id: \.id) { message in
                        MessageItem(message: message)
                    }
                    .onAppear {
                        // Use DispatchQueue to ensure UI has updated
                        DispatchQueue.main.async {
                            scroll.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.messages.count) {
                    // Use DispatchQueue to ensure UI has updated
                    DispatchQueue.main.async {
                        if let lastMessageId = viewModel.messages.last?.id {
                            withAnimation {
                                // Add withAnimation to smoothly scroll to the last message
                                scroll.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            HStack {
                TextField("Ask the book something...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        if prompt != "" {
                            viewModel.sendMessage(prompt)
                            prompt = ""
                        }
                    }
                Button("Send") {
                    viewModel.sendMessage(prompt)
                    prompt = ""
                }
                .padding()
            }
        }
        .padding()
        .frame(minWidth: 500, maxWidth: 500, minHeight: 500, maxHeight: .infinity)
        .glassBackgroundEffect()
        .onAppear {
            viewModel.setupContext(id: bookId)
            viewModel.setupOpenAI()
        }
    }
}

struct ChatViewPreviewContainer : View {
    @State var id: Book.ID? = "28c2c2c4-cc53-11ee-8d78-426536dfbd17"

    var body: some View {
        ChatView(bookId: $id)
    }
}

struct ChatPreview_Previews : PreviewProvider {
    static var previews: some View {
        ChatViewPreviewContainer()
    }
}
