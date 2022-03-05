//
//  NoteListView.swift
//  Noter
//
//  Created by Prince Embola on 08/02/2022.
//

import Foundation
import  SwiftUI
import Combine

struct NoteListView: View {
    @State var windowRef: NSWindow?
    @State private var backgroundColour: Color = Color.yellow
    @State private var backgroundImage: String = "empty"
    @ObservedObject var note: Note
    @ObservedObject var noteArray: NoteArray
    var body: some View{
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading){
                Text(note.title)
                    .font( .headline)
                    .fixedSize(horizontal: false, vertical: false)
                Spacer()
                Text(note.information)
                .font(.caption)
            }
            .padding(.trailing, 15)
            HStack{
                Spacer()
                Button(action: {noteToStickyNote(note: note)}, label:{
                    Image(systemName: "chevron.up.square")
                }) .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 0)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("note to sticky note"))
            }
        }
        .padding(5)
    }
    func noteToStickyNote(note: Note){
        let titlebarAccessoryView = ToolBar(colour: $backgroundColour, backgroundImage: $backgroundImage).padding([.top, .leading, .trailing], 0)
        let accessoryHostingView = NSHostingView(rootView:titlebarAccessoryView)
        accessoryHostingView.frame.size = accessoryHostingView.fittingSize
        let titlebarAccessory = NSTitlebarAccessoryViewController()
        titlebarAccessory.layoutAttribute = .top
        titlebarAccessory.view = accessoryHostingView
        if let curWindow = windowRef {
                   curWindow.makeKeyAndOrderFront(nil)
                   return
               }
           windowRef = NSWindow(
               contentRect: NSRect(x: 0, y: 10, width: 400, height: 400),
               styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
               backing: .buffered, defer: false)
        print("windowRef!")
        windowRef?.contentView = NSHostingView(rootView: StickyNoteWindow(note: note, backgroundColour: $backgroundColour, backgroundImage: $backgroundImage, windowRef: windowRef!, noteArray: noteArray))
        windowRef?.makeKeyAndOrderFront(nil)
        windowRef?.standardWindowButton(.miniaturizeButton)!.isHidden = true
        windowRef?.standardWindowButton(.zoomButton)!.isHidden = true
        windowRef?.isReleasedWhenClosed = false
        windowRef?.addTitlebarAccessoryViewController(titlebarAccessory)
        windowRef = windowRef
   }
    
    struct StickyNoteWindow: View
    {
        @ObservedObject var note: Note
        @Binding var backgroundColour: Color
        @Binding var backgroundImage: String
        @State var windowRef: NSWindow
        @ObservedObject var noteArray: NoteArray
        @State private var data: Note.Data = Note.Data()
        var body: some View
        {
            VStack(){
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .cornerRadius(5)
                        .frame(width: nil, height:25)
                        .foregroundColor(backgroundColour)
                        .opacity(0.7)
                    TextEditor(text: $note.title)
                        .padding(.top, 0.5)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.headline)
                        .frame(height: 25)
                        .cornerRadius(4)
                        .onDebouncedChange(
                            of: $note.title,
                            debounceFor: 1
                        ) { _ in data = note.data; note.update(from: data); note.timestamp = Date(); noteArray.updateNote(note: note)
                        }
                }.background(Image(backgroundImage).resizable(resizingMode: Image.ResizingMode.tile).frame(alignment: .topLeading).edgesIgnoringSafeArea(.all).opacity(0.2))
                ZStack(alignment: .center){ RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .cornerRadius(5)
                        .foregroundColor(backgroundColour)
                        .opacity(0.7)
                    TextEditor(text: $note.information)
                        .padding(.top, 0.5)
                        .cornerRadius(4)
                        .lineSpacing(5)
                        .onDebouncedChange(
                            of: $note.information,
                            debounceFor: 1
                        ) { _ in data = note.data; note.update(from: data); note.timestamp = Date();  noteArray.updateNote(note: note)
                        }
                }.background(Image(backgroundImage).resizable(resizingMode: Image.ResizingMode.tile).frame(alignment: .topLeading).edgesIgnoringSafeArea(.all).opacity(0.2))
            }.padding()
                .onAppear{
                    print(note)
                    data = note.data
                    data.nsWindow = windowRef
                    print(windowRef)
                    note.update(from: data)
                }
}        }
    }
