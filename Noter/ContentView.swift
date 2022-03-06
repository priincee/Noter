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
            VStack {
                Text("Notes").font(.headline)
                List(noteArray.notes, id:\.id, selection:$selectedNote) { note in
                    let r = Float(note.colour[0])
                    let g = Float(note.colour[1])
                    let b = Float(note.colour[2])
                    NoteListView(backgroundColour: Color(red:CGFloat(r!), green: CGFloat(g!), blue: CGFloat(b!)), note: note, noteArray: noteArray).tag(note)
                    }
            }
            if noteArray.notes.count == 0 {
                NoNotesView
            } else {
                if selectedNote != nil {
                    NoteDetailView(note: selectedNote!, noteArray: noteArray)
                }
            }
        }
        .navigationTitle("Stick Note")
        .onAppear {
            noteArray.getData(completion: {noteArray.subscribeToChanges(); selectInitNote()})
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSideBar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            ToolbarItem {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchString, onEditingChanged: { currentlyEditing in
                        self.hasFocus = currentlyEditing}).textFieldStyle(.plain)
                }
                .padding(.top, 5).padding(.bottom, 5).padding(.trailing, 5).padding(.leading, 5)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.gray))
            }
            ToolbarItem {
                Button(action: {refreshNotes()}) {
                    Label("Refresh Notes", systemImage: "arrow.clockwise")}
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
    
    private func selectInitNote()  {
        if noteArray.notes.count == 0
        {
            selectedNote = nil
        } else {
            selectedNote = noteArray.notes[0]
        }
    }

    private func toggleSideBar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private func addNote() {
        let newNote = Note(title: newNoteData.title, information: newNoteData.information, colour: newNoteData.colour)
        noteArray.add(note: newNote, completion: { selectedNote = noteArray.notes[0]})
        newNoteData = Note.Data()
    }
    
    private func refreshNotes() {
        noteArray.getData(completion: {noteArray.subscribeToChanges(); selectInitNote()})
    }
    
    func deleteNote(note : Note) {
        if noteArray.notes.count == 1 {
                selectedNote = nil
            } else {
                if  selectedNote == noteArray.notes[0] {
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

