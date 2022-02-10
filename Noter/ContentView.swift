//
//  ContentView.swift
//  Noter
//
//  Created by Prince Embola on 10/10/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    @Binding var notes : [Note]
    @State var searchString: String = ""
    var body: some View {
        let notes = notes.sorted {
            $0.timestamp > $1.timestamp
        }
        NavigationView {
            List {
                Text("Notes")
                    .font( .headline)
                HStack(spacing: 7){
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.gray)
                    TextField("Search", text:$searchString)
                        .textFieldStyle(.roundedBorder)
                }
                ForEach(notes) { note in
                    NavigationLink(destination: NoteDetailView(note: binding(for: note))) {
                        NoteList(note: note)
                    }
                }
                .onDelete(perform: deleteItems)  
            }
            NoteDetailView(note: binding(for: notes[0]))
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSideBar, label:{
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem {
                Button(action: addNote) {
                    Label("Add Note", systemImage: "square.and.pencil")
                }
            }
        }
    }
    
    private func binding(for note: Note) -> Binding<Note>{
       guard let noteIndex = notes.firstIndex(where : { $0.id == note.id}) else{
           fatalError("Can't find note in array")
       }
       return $notes[noteIndex]
   }

    private func toggleSideBar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private func addNote() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(notes: Note.data).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
