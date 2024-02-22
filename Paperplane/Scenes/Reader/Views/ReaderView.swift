//
//  ReaderView.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import SwiftUI
import R2Navigator

struct ReaderParams: Identifiable, Decodable, Encodable, Hashable {
    var id: Book.ID
    var url: URL
}

struct ReaderView: View {
    @Binding var params: ReaderParams?
    @Binding var isImmersive: Bool
    
    func toggleImmersion() {
        self.isImmersive.toggle()
        print("Immersion toggled: \(isImmersive)")
    }
    
        
    @State var preferences: EPUBPreferences = EPUBPreferences()
    
    var body: some View {
        NavigationSplitView (columnVisibility: .constant(.detailOnly)) {
            EmptyView()
        } detail: {
            VStack {
                if let epubURL = params?.url {
                    EPUBReaderView(url: epubURL, preferences: $preferences)
                        .ignoresSafeArea(.all)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    HStack {
                        Button(action: toggleImmersion) {
                            HStack {
                                Text(isImmersive ? "De-Immerse" : "Immerse")
                                Label("Immerse", systemImage: isImmersive ? "sparkles.tv" : "sparkles.tv.fill")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ReaderViewPreviewContainer : View {
    @State private var params: ReaderParams? = ReaderParams(id: "example", url: Bundle.main.url(forResource: "example", withExtension: "epub")!)
    @State private var isImmersive: Bool = true
    
    var body: some View {
        ReaderView(params: $params, isImmersive: $isImmersive)
    }
}

struct ReaderPreview_Previews : PreviewProvider {
    static var previews: some View {
        ReaderViewPreviewContainer()
    }
}
