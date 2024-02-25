//
//  ChatView.swift
//  Paperplane
//
//  Created by tyler on 2/24/24.
//

import Foundation
import SwiftUI
import OpenAISwift

struct ChatView: View {
    @Binding var sheetVisible: Bool
    @StateObject private var viewModel = ChatViewModel()
    @State private var prompt: String = ""

    var body: some View {
        VStack {
            Button(action: {
                sheetVisible = false
            }) {
                Image(systemName: "xmark")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()

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
                TextField("Type your message here...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        viewModel.sendMessage(prompt)
                        prompt = ""
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
            viewModel.setupOpenAI()
        }
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private var openAI: OpenAISwift?
    
    init() {}
    
    func setupOpenAI() {
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey: apiKey)
            openAI = OpenAISwift(config: config)
            print("open ai initialized")
        } else {
            print("open ai failed to initialize")
        }
    }

    func sendMessage(_ message: String) {
        // append user message
        messages.append(ChatMessage(role: .user, content: message))
        
        Task {
            do {
                let result = try await openAI?.sendChat(
                    with: messages,
                    model: .gpt4,         // optional `OpenAIModelType`
                    user: nil,                      // optional `String?`
                    temperature: 1,                 // optional `Double?`
                    topProbabilityMass: 1,          // optional `Double?`
                    choices: 1,                     // optional `Int?`
                    stop: nil,                      // optional `[String]?`
                    maxTokens: 500,                 // optional `Int?`
                    presencePenalty: nil,           // optional `Double?`
                    frequencyPenalty: nil,          // optional `Double?`
                    logitBias: nil                 // optional `[Int: Double]?` (see inline documentation)
                )
                
                if let response = result {
                    if let responseMessage = response.choices?[0].message {
                        self.messages.append(responseMessage)
                        print("oai message received: \(response)")
                    }
                }
            } catch {
                print("OpenAI failed with error: \(error)")
            }
        }
    }
}

struct MessageItem: View {
    var message: ChatMessage
    var body: some View {
        VStack {
            Text(message.role == .user ? "You" : "Robot" )
                .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
            HStack {
                if message.role == .user {
                    Spacer()
                }
                Text(message.content ?? "")
                    .padding()
                    .background(Rectangle().fill(message.role == .user ? Color.blue.opacity(0.2) : Color.green.opacity(0.2)))
                    .cornerRadius(10)
                if message.role != .user {
                    Spacer()
                }
            }
        }
        .padding()
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
