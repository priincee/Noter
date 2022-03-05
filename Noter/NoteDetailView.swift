//
//  NoteDetailView.swift
//  Noter
//
//  Created by Prince Embola on 14/10/2021.
//

import SwiftUI
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }

    }
}

struct NoteDetailView: View {
    @ObservedObject var note: Note
    @ObservedObject var noteArray: NoteArray
    @State private var data: Note.Data = Note.Data()
    var body: some View {
            VStack(){
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .frame(width: nil, height:25)
                        .cornerRadius(5)
                        .foregroundColor(Color.gray)
                        .opacity(0.3)
                    TextEditor(text: $note.title)
                        .padding(.top, 0.5)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.headline)
                        .frame(height: 25)
                        .cornerRadius(5)
                        .onDebouncedChange(
                            of: $note.title,
                            debounceFor: 1
                        ) { _ in data = note.data; note.update(from: data); note.timestamp = Date(); noteArray.updateNote(note: note)
                        }
                }
                ZStack(alignment: .center){ RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .foregroundColor(Color.gray)
                        .cornerRadius(5)
                        .opacity(0.3)
                    TextEditor(text: $note.information)
                        .padding(.top, 0.5)
                        .cornerRadius(4)
                        .lineSpacing(5)
                        .onDebouncedChange(
                            of: $note.information,
                            debounceFor: 1
                        ) { _ in data = note.data; note.update(from: data); note.timestamp = Date(); noteArray.updateNote(note: note)
                        }
                }
                Text("Last Modified on: \(note.timestamp, formatter: itemFormatter)")
            }
        .padding()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
