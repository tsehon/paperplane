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
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @Binding var params: ReaderParams?
    @State private var navigator: EPUBNavigatorViewController?
    @State private var publication: Publication?
    @State private var locator: Locator?
    
    @State private var isSpaceHidden: Bool = true
    @State private var navVisibility: NavigationSplitViewVisibility = .detailOnly
    @State var preferences: EPUBPreferences = EPUBPreferences(
        columnCount: .two)
    @State private var readerAspectRatio: CGSize = CGSize(width: 9, height: 16)
    @State private var isChatboxVisible = false
    
    // fetch highlights from database for user
    // @State var highlights
    // let decorations = highlights.map { highlight in Decoration(id: highlight.id...)
    
    /*
     /// Current position in the publication.
     /// Can be used to save a bookmark to the current position.
     NAV: var currentLocation: Locator? { get }
     */
    
    var body: some View {
        NavigationSplitView (columnVisibility: $navVisibility) {
            let _ = print("reader aspect: \(readerAspectRatio)")
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
                    EPUBReaderView(url: epubURL, preferences: $preferences, navigator: $navigator, publication: $publication, locator: $locator, chatboxVisible: $isChatboxVisible)
                        .ignoresSafeArea(.all)
                        //.scaledToFit() <- gets true size, but window is too wide, not fit. 
                        .background(BookGeometry())
                        .onPreferenceChange(WidthPreferenceKey.self, perform: { self.readerAspectRatio = $0 })
                    /*
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded({ value in
                            print("long press: \(value)")
                        }))
                     */
                }
            }
            .sheet(isPresented: $isChatboxVisible) {
                ChatView(sheetVisible: $isChatboxVisible)
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
                            if Thread.isMainThread {
                                dismissWindow(id: "reader")
                                openWindow(id: "home")
                            } else {
                                DispatchQueue.main.sync {
                                    dismissWindow(id: "reader")
                                    openWindow(id: "home")
                                }
                            }
                            Task {
                                if !isSpaceHidden {
                                    await dismissImmersiveSpace()
                                }
                            }
                        }, label: {
                            Image(systemName: "house")
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
        }.onAppear {
            if Thread.isMainThread {
                dismissWindow(id: "home")
            } else {
                DispatchQueue.main.sync {
                    dismissWindow(id: "home")
                }
            }
        }
        .glassBackgroundEffect(displayMode: .never)
        .frame(idealWidth: 1000, idealHeight: 1400)
    }
}

struct BookGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            return Rectangle().fill(Color.clear).preference(key: WidthPreferenceKey.self, value: CGSize(width: geometry.size.width , height: geometry.size.height))
        }
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = CGSize(width: 9, height: 16)

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }

    typealias Value = CGSize
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
