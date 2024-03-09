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
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        if authViewModel.authenticationState == .authenticated {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                ExploreView()
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                UserProfileView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical")
                    }
            }
        } else {
            AuthenticationView()
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
