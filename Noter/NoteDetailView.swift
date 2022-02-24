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
    @State private var data: Note.Data = Note.Data()
    var body: some View {
            VStack(){
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .border(Color.gray, width: 1.5)
                        .frame(width: nil, height:25)
                        .foregroundColor(Color.white)
                        .opacity(0.1)
                    TextEditor(text: $note.title)
                        .padding(.top, 3)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.headline)
                        .frame(height: 25)
                        .cornerRadius(5)
                        .onDebouncedChange(
                            of: $note.title,
                            debounceFor: 2
                        ) { _ in data = note.data; print("changedT"); note.update(from: data); note.timestamp = Date()
                        }
                }
                ZStack(alignment: .center){ RoundedRectangle(cornerRadius: 5,style: .continuous).border(Color.gray, width: 1.5)
                        .foregroundColor(Color.white)
                        .opacity(0.1)
                    TextEditor(text: $note.information)
                        .padding(.top, 5)
                        .cornerRadius(5)
                        .lineSpacing(5)
                        .onDebouncedChange(
                            of: $note.information,
                            debounceFor: 2
                        ) { _ in data = note.data; note.update(from: data); note.timestamp = Date()
                        }
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
