//
//  MainAppView.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/10/24.
//

import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @State private var isLoggedIn = false

    var body: some View {
        VStack {
            if isLoggedIn {
                MainContentView()  // If already logged in, show main content
            } else {
                LoginView(isLoggedIn: $isLoggedIn)  // If not logged in, show login view
            }
        }
        .onAppear {
            // Check if the user is already logged in
            checkLoginStatus()
        }
    }

    func checkLoginStatus() {
        // Check current user login status using Firebase
        if Auth.auth().currentUser != nil {
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
        }
    }
}

