//
//  NoteList.swift
//  Noter
//
//  Created by Prince Embola on 18/02/2022.
//

import Foundation
import SwiftUI

struct NoteList: View {
  @Binding var notes: [Note]
  @Binding var selectedNote: Note?

  var body: some View {
      
    List(notes, id: \.self, selection: $selectedNote) { note in // persons is an array of persons
        NoteListView(note: binding(for: note)).tag(note)
    }
  }
    
    
    private func binding(for note: Note) -> Binding<Note>{
       guard let noteIndex = notes.firstIndex(where : { $0.id == note.id}) else{
           fatalError("Can't find note in array")
       }
       return $notes[noteIndex]
   }
}
