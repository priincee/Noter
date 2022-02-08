//
//  NoteDetailView.swift
//  Noter
//
//  Created by Prince Embola on 14/10/2021.
//

import SwiftUI

struct NoteDetailView: View {
    var note: Note
    var body: some View {
        Text(note.title)
            .font( .headline)
        Text(note.information)
    }
}

//struct NoteDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteDetailView().frame(minWidth: 6000, idealWidth: nil, maxWidth: nil, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
//    }
//}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
