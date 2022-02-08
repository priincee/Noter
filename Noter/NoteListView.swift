//
//  NoteListView.swift
//  Noter
//
//  Created by Prince Embola on 08/02/2022.
//

import Foundation
import  SwiftUI

struct NoteList: View {
    let note: Note
    var body: some View{
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading){
                Text(note.title)
                    .font( .headline)
                Spacer()
                Text(note.information)
                .font(.caption)
            }
            HStack{
                Spacer()
                Button(action: noteToStickyNote, label:{
                    Image(systemName: "chevron.up.square")
                }) .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 0)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("note to sticky note"))
            }
        }
        .padding(5)
        
    }
}

func noteToStickyNote(){
    
}
