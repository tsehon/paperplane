//
//  ReaderToolbar.swift
//  Paperplane
//
//  Created by tyler on 2/24/24.
//

import SwiftUI
import R2Shared
import R2Navigator

struct ReaderToolbar : View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @Binding var navigator: EPUBNavigatorViewController?
    @Binding var publication: Publication?
    @Binding var locator: Locator? // TODO: add an editable with page number
    @Binding var isSpaceHidden: Bool
    @Binding var isTableOfContentsVisible: NavigationSplitViewVisibility
    @Binding var isChatboxVisible: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                isTableOfContentsVisible = isTableOfContentsVisible == .detailOnly ? .all : .detailOnly
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
                isChatboxVisible = !isChatboxVisible
            }, label: {
                Image(systemName: "info.bubble")
            })
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

            /*
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
             */
