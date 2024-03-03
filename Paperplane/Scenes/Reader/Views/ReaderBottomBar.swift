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

struct ReaderBottomBar: View {
    var bookId: Book.ID?
    @Binding var isSidebarVisible: NavigationSplitViewVisibility
    @Binding var isChatWindowOpen: Bool
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

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
                if ImmersiveSpaceService.shared.isOpen {
                    Task {
                        ImmersiveSpaceService.shared.updateEnv("none")
                    }
                }
            }, label: {
                Image(systemName: "house")
            })
            Button(action: {
                if !isChatWindowOpen, let id = bookId {
                    if Thread.isMainThread {
                        openWindow(id: "chat", value: id as Book.ID)
                    } else {
                        DispatchQueue.main.sync {
                            openWindow(id: "chat", value: id as Book.ID)
                        }
                    }
                }
            }, label: {
                Image(systemName: "bubble")
            })
        }
    }
}

