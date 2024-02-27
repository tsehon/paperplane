//
//  ReaderNavBar.swift
//  Paperplane
//
//  Created by tyler on 2/25/24.
//

import Foundation
import SwiftUI
import R2Shared
import R2Navigator

struct ReaderTabBar: View {
    @ObservedObject var viewModel: NavigatorViewModel
    @Binding var isVisible: NavigationSplitViewVisibility
    @Binding var isSpaceHidden: Bool
    
    @State private var navigationTitle = "Table of Contents"
    
    var body: some View {
        TabView {
            TableOfContents(viewModel: viewModel)
            .tabItem { Label("Table Of Contents", systemImage: "text.book.closed") }
            .onAppear {
                self.navigationTitle = "Table of Contents"
            }
            EnvironmentMenu(isSpaceHidden: $isSpaceHidden)
            .tabItem { Label("Environment", systemImage: "mountain.2.fill") }
            .onAppear {
                self.navigationTitle = "Select an environment"
            }
        }
        .navigationTitle(self.navigationTitle)
    }
}

struct TableOfContents: View {
    @ObservedObject var viewModel: NavigatorViewModel
    
    var body: some View {
        if let toc = viewModel.publication?.tableOfContents, let nav = viewModel.navigator {
            List {
                ForEach(toc, id: \.href) { link in
                    Button(action: {
                        let success = nav.go(to: link)
                        if !success {
                            print("Table of Contents link failed")
                        }
                    }){
                        Text(link.title ?? "Untitled")
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct EnvironmentMenu: View {
    @Binding var isSpaceHidden: Bool

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        ScrollView {
            Button("\(isSpaceHidden ? "Open" : "Close") Immersion") {
                Task {
                    if isSpaceHidden {
                        let result: OpenImmersiveSpaceAction.Result = await openImmersiveSpace(id: "immersive-reader")
                        switch result {
                        case .opened:
                            print("Immersive space opened")
                            isSpaceHidden = false
                        case .userCancelled:
                            print("User cancelled")
                            isSpaceHidden = true
                        case .error:
                            print("An error occurred")
                            isSpaceHidden = true
                        default:
                            return
                        }
                    } else {
                        await dismissImmersiveSpace()
                        isSpaceHidden = true
                    }
                }
            }
        }
    }
}
