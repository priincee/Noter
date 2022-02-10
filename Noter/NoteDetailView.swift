//
//  NoteDetailView.swift
//  Noter
//
//  Created by Prince Embola on 14/10/2021.
//

import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @State private var data: Note.Data = Note.Data()
    var body: some View {
            VStack(){
                TextEditor(text: $note.title)
                    .font(.headline)
                    .frame(height: 25)
                    .cornerRadius(10)
                    .onDebouncedChange(
                        of: $note.title,
                        debounceFor: 2
                    ) { _ in data = note.data; note.update(from: data); note.timestamp = Date()
                    }
                TextEditor(text: $note.information)
                    .cornerRadius(10)
                    .lineSpacing(5)
                    .onDebouncedChange(
                        of: $note.information,
                        debounceFor: 1
                    ) { _ in data = note.data; note.update(from: data); note.timestamp = Date()
                    }
                Text("Last Modified on: \(note.timestamp, formatter: itemFormatter)")
            }
        .padding()
    }
}

private func saveToCloud(s:Binding<Note.Data>, d: Binding<Note>){
    print(s)
    print("saved title")
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
