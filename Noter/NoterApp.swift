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
   
    @StateObject var noteArray = NoteArray()
    var body: some Scene {
        WindowGroup {
            ContentView(noteArray: noteArray)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(noteArray)
        }
    }
}

