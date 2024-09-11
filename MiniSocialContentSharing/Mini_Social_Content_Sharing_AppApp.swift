//
//  Mini_Social_Content_Sharing_AppApp.swift
//  Mini Social Content Sharing App
//
//  Created by Qiaochu Zhang on 9/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct YourApp: App {
    // Configure Firebase
    init() {
        FirebaseApp.configure()
        // Enable Firebase debug logging
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
    }

    var body: some Scene {
        WindowGroup {
            MainAppView()   // Show MainAppView on launch
        }
    }
}
