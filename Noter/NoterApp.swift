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
    @State private var notes = Note.data
    var body: some Scene {
        WindowGroup {
            ContentView(notes: $notes)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
