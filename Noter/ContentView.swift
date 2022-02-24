//
//  ContentView.swift
//  Noter
//
//  Created by Prince Embola on 10/10/2021.
//

import SwiftUI
import CoreData

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct ContentView: View {
    @ObservedObject var noteArray: NoteArray
    @State private var searchString: String = ""
    @State private var newNoteData = Note.Data()
    @State private var selectedNote: Note?
    @State private var hasFocus = false
    @State private var isPresentingDeletionConfirmation: Bool = false
    var body: some View {
        NavigationView {
            VStack{
                List(noteArray.notes, id:\.id, selection:$selectedNote){ note in
                        NoteListView(note: note).tag(note)
                    }
            }
//            List{
//                Text("Notes").padding(.leading, 60)
//                    .font( .headline)
//                ForEach(noteArray.notes.indices, id: \.self) { index in
//                    NavigationLink(destination: NoteDetailView(note: noteArray.notes[index])) {
//                        HStack{
//                            Button(action: {deleteNote(index: index)}, label:{
//                                Image(systemName: "xmark")
//                            }) .buttonStyle(PlainButtonStyle())
//                                .padding(.leading, 0)
//                                .accessibilityElement(children: .ignore)
//                                .accessibilityLabel(Text("delete note"))
//                            NoteListView(note: $noteArray.notes[index])
//                        }
//                    }
//                }
//            }
            if noteArray.notes.count == 0 {
                NoNotesView
            } else {
                if selectedNote != nil{
                    NoteDetailView(note: selectedNote!)
                }
            }
        }
        .onAppear{
            if noteArray.notes.count == 0
            {
                selectedNote = nil
            } else{
                selectedNote = noteArray.notes[0]
            }
            
//            notes = notes.sorted {
//                $0.timestamp < $1.timestamp
//            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSideBar, label:{
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem{
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchString, onEditingChanged: { currentlyEditing in
                        self.hasFocus = currentlyEditing}).textFieldStyle(.plain)
                }
                .padding(.top, 5).padding(.bottom, 5).padding(.trailing, 5).padding(.leading, 5)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.gray))
            }
                ToolbarItem {
                    if selectedNote != nil {
                        Button(action: {isPresentingDeletionConfirmation = true}) {
                            Label("Delete Note", systemImage: "trash")
                        }.alert(isPresented: $isPresentingDeletionConfirmation) {
                            Alert(
                                title: Text("Are you sure you want to delete"),
                                message: Text(selectedNote!.title),
                                primaryButton: .default(
                                    Text("No"), action: {isPresentingDeletionConfirmation = false}),
                                secondaryButton: .destructive(
                                    Text("Yes"),
                                    action: {deleteNote(note: selectedNote!); isPresentingDeletionConfirmation = false }
                                )
                            )
                        }
                    }
                }
            
            ToolbarItem {
                Button(action: {addNote()}) {
                    Label("Add Note", systemImage: "square.and.pencil")
                }
            }
        }
    }

    private func toggleSideBar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private func addNote() {
        print("tried to add")
        let newNote = Note(title: newNoteData.title, information: newNoteData.information)
        noteArray.add(note: newNote)
        selectedNote = newNote
        newNoteData = Note.Data()
        noteArray.subscribeToChanges()
    }
    
    func deleteNote(note : Note) {
        if noteArray.notes.count == 1 {
                selectedNote = nil
            } else {
                if  selectedNote == noteArray.notes[0] {
                    print("this is note 0")
                    selectedNote = noteArray.notes[1]
                }
                else{
                    selectedNote = noteArray.notes[0]
                }
            }
        if note.nsWindow != nil {
            note.nsWindow?.close()
            }
            noteArray.remove(note: note)
    }
    
    var NoNotesView: some View {
        Text("Oops, looks like you have no notes...")
    }

}

