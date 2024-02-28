//
//  TabBar.swift
//  Paperplane
//
//  Created by tyler on 2/18/24.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            Text("adfajklsdfhjklajsdfh")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    TabBar()
}
