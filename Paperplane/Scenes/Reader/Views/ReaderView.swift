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
    
    @State private var readerAspectRatio: CGSize = CGSize(width: 9, height: 16)
    @State private var isSpaceHidden: Bool = true
    @State private var isTableOfContentsVisible: NavigationSplitViewVisibility = .detailOnly
    @State var preferences: EPUBPreferences = EPUBPreferences(
        columnCount: .two)
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
        NavigationSplitView (columnVisibility: $isTableOfContentsVisible) {
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
                    ReaderToolbar(navigator: $navigator, publication: $publication, locator: $locator, isSpaceHidden: $isSpaceHidden, isTableOfContentsVisible: $isTableOfContentsVisible, isChatboxVisible: $isChatboxVisible)
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
