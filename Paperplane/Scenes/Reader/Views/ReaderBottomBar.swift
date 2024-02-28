//
//  ReaderToolbar.swift
//  Paperplane
//
//  Created by tyler on 2/24/24.
//

import SwiftUI
import R2Shared
import R2Navigator
import Combine

struct ReaderToolbar : View {
    @Binding var isSidebarVisible: NavigationSplitViewVisibility
    @Binding var isChatWindowOpen: Bool
    @Binding var pageNum: String
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    

    var body: some View {
        HStack {
            Button(action: {
                isSidebarVisible = isSidebarVisible == .detailOnly ? .all : .detailOnly
            }, label: {
                Image(systemName: "sidebar.left")
            })
            Button(action: {
                if Thread.isMainThread {
                    //dismissWindow(id: "reader")
                    openWindow(id: "home")
                } else {
                    DispatchQueue.main.sync {
                        //dismissWindow(id: "reader")
                        openWindow(id: "home")
                    }
                }
                Task {
                    await dismissImmersiveSpace()
                }
            }, label: {
                Image(systemName: "house")
            })
            Button(action: {
                if !isChatWindowOpen {
                    if Thread.isMainThread {
                        openWindow(id: "chat")
                    } else {
                        DispatchQueue.main.sync {
                            openWindow(id: "chat")
                        }
                    }
                }
            }, label: {
                Image(systemName: "bubble")
            })
            Button(action: {
               // nothing now
            }, label: {
                Text(pageNum)
            })
        }
    }
}

