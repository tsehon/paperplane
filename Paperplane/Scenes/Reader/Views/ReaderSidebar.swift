//
//  ReaderNavBar.swift
//  Paperplane
//
//  Created by tyler on 2/25/24.
//

import Foundation
import SwiftUI
import R2Navigator

struct ReaderSidebar: View {
    let id: Book.ID?
    @ObservedObject var viewModel: NavigatorViewModel
    @Binding var isVisible: NavigationSplitViewVisibility

    @State private var navigationTitle = "Table of Contents"
    
    var body: some View {
        TabView {
            TableOfContents(viewModel: viewModel)
            .tabItem { Label("Table Of Contents", systemImage: "list.bullet") }
            .onAppear {
                self.navigationTitle = "Table of Contents"
            }
            EnvironmentMenu(id: id)
            .tabItem { Label("Environment", systemImage: "mountain.2.fill") }
            .onAppear {
                self.navigationTitle = "Environment Selection"
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
                        print(link)
                        let success = nav.go(to: link)
                        if !success {
                            print("Table of Contents link failed")
                        }
                    }){
                        Text(link.title ?? "Untitled")
                            .foregroundStyle(link.href.contains(viewModel.sectionLink) ? Color.blue : Color.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
        } else {
            EmptyView()
        }
    }
}

@MainActor
struct EnvironmentMenu: View {
    let id: Book.ID?
    @ObservedObject var spaceService = ImmersiveSpaceService.shared
    
    let noneEnv: ImmersiveEnvironment = ImmersiveEnvironment(id: "none", title: "None")
    let genEnv: ImmersiveEnvironment = ImmersiveEnvironment(id: "gen", title: "Generated")
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach([noneEnv, genEnv] + spaceService.environments, id: \.id) { env in
                    EnvironmentButton(env: env)
                }
            }
        }
    }
}

@MainActor
struct EnvironmentButton: View {
    @ObservedObject var spaceService = ImmersiveSpaceService.shared
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    let env: ImmersiveEnvironment
    
    var body: some View {
        Button(action: {
            if spaceService.currentEnvId == "none" {
                Task {
                    let result: OpenImmersiveSpaceAction.Result = await openImmersiveSpace(id: "immersive-reader")
                    switch result {
                    case .opened:
                        print("space service opened")
                    case .userCancelled:
                        print("\(#function) User cancelled")
                    case .error:
                        print("\(#function) An error occurred")
                    default:
                        return
                    }
                }
            }
            spaceService.updateEnv(env.id)
        }) {
            HStack {
                Text(env.title.capitalized) // This capitalizes the first letter of each word
                    .padding() // Add padding to make the background larger than the text
                    .foregroundColor(.white) // Set the text color to white (or any color you prefer)

                Spacer()
            }
            .padding(.horizontal) // Add horizontal padding around the button
            .background(spaceService.currentEnvId == env.id ? Color.blue.opacity(0.1) : Color.clear)
            .contentShape(RoundedRectangle(cornerRadius: 25))
            .cornerRadius(25)
            .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(spaceService.currentEnvId == env.id ? Color.blue : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct SidebarPreviewContainer: View {
    @StateObject var viewModel = NavigatorViewModel()
    private var preferences = EPUBPreferences()
    
    var body: some View {
        NavigationSplitView(sidebar: {
            ReaderSidebar(id: "example", viewModel: viewModel, isVisible: .constant(.all))
        }, detail: {
            EPUBReaderView(url: Bundle.main.url(forResource: "example", withExtension: "epub")!, viewModel: viewModel, preferences: .constant(preferences), contextSheetVisible: .constant(false))
        })
    }
}

struct EnvironmentMenuPreview_Previews : PreviewProvider {
    static var previews: some View {
        SidebarPreviewContainer()
    }
}
