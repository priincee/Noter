//
//  NoterApp.swift
//  Noter
//
//  Created by Prince Embola on 10/10/2021.
//

import SwiftUI

@main
struct NoterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(notes: Note.data)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
