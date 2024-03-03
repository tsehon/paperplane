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
import Combine

struct ReaderParams: Identifiable, Decodable, Encodable, Hashable {
    var id: Book.ID
    var url: URL
}

struct ReaderView: View {
    @Binding var params: ReaderParams?
    @StateObject var viewModel = NavigatorViewModel()

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var readerAspectRatio: CGSize = CGSize(width: 9, height: 16)
    @State private var isContextSheetVisible: Bool = false
    @State private var isSidebarVisible: NavigationSplitViewVisibility = .detailOnly
    @State var preferences: EPUBPreferences = EPUBPreferences(
        columnCount: .two)
    @State var isChatWindowOpen: Bool = false
    @State var pageNum: Int = 0

    // fetch highlights from database for user
    // @State var highlights
    // let decorations = highlights.map { highlight in Decoration(id: highlight.id...)
    
    /*
     /// Current position in the publication.
     /// Can be used to save a bookmark to the current position.
     NAV: var currentLocation: Locator? { get }
     */
    
    var body: some View {
        NavigationSplitView (columnVisibility: $isSidebarVisible) {
            ReaderSidebar(id: params?.id, viewModel: viewModel, isVisible: $isSidebarVisible)
        } detail: {
            VStack {
                if let epubURL = params?.url {
                    EPUBReaderView(url: epubURL, viewModel: viewModel, preferences: $preferences, contextSheetVisible: $isContextSheetVisible)
                        .ignoresSafeArea(.all)
                        .background(BookGeometry())
                        .onPreferenceChange(WidthPreferenceKey.self, perform: { self.readerAspectRatio = $0 })
                }
            }
            .sheet(isPresented: $viewModel.infoSheetVisible) {
                //LookupSheet(data: "ex prompt")
                EmptyView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    ReaderBottomBar(bookId: params?.id, isSidebarVisible: $isSidebarVisible, isChatWindowOpen: $isChatWindowOpen)
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
        .overlay(alignment: .bottom) {
            Text("\(viewModel.pageNum)")
                .foregroundStyle(.black)
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
