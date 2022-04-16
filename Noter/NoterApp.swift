//
//  NoterApp.swift
//  Noter
//
//  Created by Prince Embola on 10/10/2021.

import SwiftUI
import Firebase

@main
struct NoterApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            let appViewModel = AppViewModel()
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}
