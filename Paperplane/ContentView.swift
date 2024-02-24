//
//  ContentView.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            HomeView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
        .frame(minWidth: 800, maxWidth: 2000, minHeight: 800, maxHeight: 1600)
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
