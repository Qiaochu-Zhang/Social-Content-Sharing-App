//
//  MainContentView.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/10/24.
//

import SwiftUI

struct MainContentView: View {
    var body: some View {
        TabView {
            ContentUploadView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Upload")
                }
            
            ContentListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Content List")
                }
            
            UserContentView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Your Posts")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
    }
}
