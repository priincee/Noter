//
//  NoteView.swift
//  Noter
//
//  Created by Prince Embola on 14/10/2021.
//

import SwiftUI

struct NoteView: View {
    let note: Note
    var body: some View {
        
        Text(note.title)
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView(note:Note.data[0])
    }
}
