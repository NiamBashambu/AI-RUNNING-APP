//
//  airunningApp.swift
//  airunning
//
//  Created by Niam Bashambu on 9/28/24.
//

import SwiftUI

@main
struct airunningApp: App {
    init() {
            // Set the appearance for the app to use system background color
            UINavigationBar.appearance().backgroundColor = UIColor.systemBackground
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
        }
    var body: some Scene {
        WindowGroup {
            ContentView()


        }
    }
    
}
