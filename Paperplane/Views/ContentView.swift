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
            HomeView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            HomeView()
                .tabItem {
                    Label("Wish List", systemImage: "heart")
                }
            HomeView()
                .tabItem {
                    Label("Notes", systemImage: "book.pages")
                }
            HomeView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
            HomeView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
