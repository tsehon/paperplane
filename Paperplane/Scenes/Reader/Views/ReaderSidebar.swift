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
    
    @State private var navigationTitle = "Table of Contents"
    
    var body: some View {
        TabView {
            TableOfContents(viewModel: viewModel)
            .tabItem { Label("Table Of Contents", systemImage: "text.book.closed") }
            .onAppear {
                self.navigationTitle = "Table of Contents"
            }
            EnvironmentMenu()
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
    @ObservedObject var spaceService = ImmersiveSpaceService.shared
    
    var noneEnv: ImmersiveEnvironment = ImmersiveEnvironment(id: "none", title: "None")
    var genEnv: ImmersiveEnvironment = ImmersiveEnvironment(id: "gen", title: "Generated")
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @MainActor
    func openEnvironment() async {
        let result: OpenImmersiveSpaceAction.Result = await openImmersiveSpace(id: "immersive-reader")
        switch result {
        case .opened:
            print("space service opened")
        case .userCancelled:
            print("\(#function) User cancelled")
            spaceService.isOpen = false
        case .error:
            print("\(#function) An error occurred")
            spaceService.isOpen = false
        default:
            return
        }
    }

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @MainActor
    func closeEnvironment() async {
        await dismissImmersiveSpace()
    }
    

    var body: some View {
        List {
            EnvironmentButton(env: noneEnv)
            EnvironmentButton(env: genEnv)
            ForEach(spaceService.environments, id: \.id) { env in
                EnvironmentButton(env: env)
            }
        }
        .onChange(of: spaceService.isOpen) {
            if spaceService.isOpen {
                Task {
                    await openEnvironment()
                }
            } else {
                Task {
                    await closeEnvironment()
                }
            }
        }
    }
}

struct EnvironmentButton: View {
    @ObservedObject var spaceService = ImmersiveSpaceService.shared
    let env: ImmersiveEnvironment
    
    var body: some View {
        Button(env.title) {
            spaceService.updateEnv(env.id)
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(lineWidth: 3.0).foregroundColor(spaceService.currentEnvId == env.id ? Color.blue : Color.clear)
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
        )
    }
}
