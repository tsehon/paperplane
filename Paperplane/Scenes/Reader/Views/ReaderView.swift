//
//  ReaderView.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI
import R2Navigator
import R2Shared

struct ReaderParams: Identifiable, Decodable, Encodable, Hashable {
    var id: Book.ID
    var url: URL
}

struct ReaderView: View {
    @Binding var params: ReaderParams?
    
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var navigator: EPUBNavigatorViewController?
    @State private var publication: Publication?
    @State private var locator: Locator?
    
    @State private var isSpaceHidden: Bool = true
    @State private var navVisibility: NavigationSplitViewVisibility = .detailOnly
    @State var preferences: EPUBPreferences = EPUBPreferences()
    // fetch highlights from database for user
    // @State var highlights
    // let decorations = highlights.map { highlight in Decoration(id: highlight.id...)
    
    /*
     /// Current position in the publication.
     /// Can be used to save a bookmark to the current position.
     NAV: var currentLocation: Locator? { get }
     */

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        NavigationSplitView (columnVisibility: $navVisibility) {
            if let toc = publication?.tableOfContents, let nav = navigator {
                List {
                    ForEach(toc, id: \.href) { link in
                        Button(action: {
                            let success = nav.go(to: link)
                            if !success {
                                print("Table of Contents link failed")
                            }
                        }){
                            Text(link.title ?? "")
                        }
                    }
                }
                .navigationTitle("Table of Contents")
            } else {
                EmptyView()
            }
        } detail: {
            VStack {
                if let epubURL = params?.url {
                    EPUBReaderView(url: epubURL, preferences: $preferences, navigator: $navigator, publication: $publication, locator: $locator)
                        .ignoresSafeArea(.all)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    HStack {
                        Button(action: {
                            navVisibility = navVisibility == .detailOnly ? .all : .detailOnly
                        }, label: {
                           Image(systemName: "sidebar.left")
                        })
                        Button(action: {
                            navigator?.goBackward(animated: true)
                        }, label: {
                           Image(systemName: "arrow.left")
                        })
                        Button(action: {
                            navigator?.goForward(animated: true)
                        }, label: {
                           Image(systemName: "arrow.right")
                        })
                        Button("Show Immersive Space") {
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
            .frame(minWidth: 1000, idealWidth: 1000, maxWidth: 2000, minHeight: 1000, idealHeight: 1000, maxHeight: 2000)
        }.onAppear {
            dismissWindow(id: "home")
        }
    }
}

struct ReaderViewPreviewContainer : View {
    @State private var params: ReaderParams? = ReaderParams(id: "example", url: Bundle.main.url(forResource: "example", withExtension: "epub")!)
    
    var body: some View {
        ReaderView(params: $params)
    }
}

struct ReaderPreview_Previews : PreviewProvider {
    static var previews: some View {
        ReaderViewPreviewContainer()
    }
}
