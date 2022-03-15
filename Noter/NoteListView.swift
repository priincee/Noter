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
    @EnvironmentObject var appViewModel: AppViewModel
    @State var windowRef: NSWindow?
    @State var backgroundColour: Color = Color.yellow
    @State private var backgroundImage: String = "empty"
    @ObservedObject var note: Note
    @ObservedObject var noteArray: NoteArray
    var body: some View{
        VStack {
            HStack {
                Text(note.title)
                    .font( .headline)
                    .fixedSize(horizontal: false, vertical: false)
                Spacer()
                Button(action: {noteToStickyNote(note: note)}, label:{
                    Image(systemName: "note.text")
                }) .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 0)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("note to sticky note"))
            }
            HStack {
                Text(note.information)
                    .font(.caption)
                Spacer()
            }.padding(.top, 1)
            HStack{
                Circle().foregroundColor(backgroundColour).frame(width: 10, height: 10)
                Spacer()
                Text("\((note.timestamp).timeAgoDisplay())").font(.caption).foregroundColor(Color.gray)
            }
            RoundedRectangle(cornerRadius: 0,style: .continuous)
                .frame(width: nil, height:1).border(Color.gray, width: 2)
        }
        .onChange(of: note.colour) { bg in
            print("colour changed")
            print(note.colour)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let r = Float(note.colour[0])
                let g = Float(note.colour[1])
                let b = Float(note.colour[2])
                print(note.colour)
                backgroundColour = Color(red:CGFloat(r!), green: CGFloat(g!), blue: CGFloat(b!))
            }
            
        }
        .onAppear{
            let r = Float(note.colour[0])
            let g = Float(note.colour[1])
            let b = Float(note.colour[2])
            backgroundColour = Color(red:CGFloat(r!), green: CGFloat(g!), blue: CGFloat(b!))
        }
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
        windowRef?.contentView = NSHostingView(rootView: StickyNoteWindow(note: note, backgroundColour: $backgroundColour, backgroundImage: $backgroundImage, windowRef: windowRef!, noteArray: noteArray).environmentObject(appViewModel))
        windowRef?.makeKeyAndOrderFront(nil)
        windowRef?.standardWindowButton(.miniaturizeButton)!.isHidden = true
        windowRef?.standardWindowButton(.zoomButton)!.isHidden = true
        windowRef?.isReleasedWhenClosed = false
        windowRef?.addTitlebarAccessoryViewController(titlebarAccessory)
        windowRef = windowRef
    }
    
    struct StickyNoteWindow: View
    {
        @EnvironmentObject var appViewModel: AppViewModel
        @ObservedObject var note: Note
        @Binding var backgroundColour: Color
        @Binding var backgroundImage: String
        @State var windowRef: NSWindow
        @ObservedObject var noteArray: NoteArray
        @State private var data: Note.Data = Note.Data()
        var body: some View
        {
            ZStack{
                backgroundColour.ignoresSafeArea()
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
                            ) { _ in data = note.data; note.update(from: data); note.timestamp = Date(); noteArray.updateNote(userId: appViewModel.currentUserId(), note: note)
                            }
                    }.background(Image(backgroundImage).resizable(resizingMode: Image.ResizingMode.tile).frame(alignment: .topLeading).edgesIgnoringSafeArea(.all).opacity(0.2))
                    ZStack(alignment: .center){ RoundedRectangle(cornerRadius: 5,style: .continuous)
                            .cornerRadius(5)
                            .foregroundColor(backgroundColour).onChange(of: backgroundColour) { bg in
                                print("changed colour"); note.updateColourFromPicker(color: backgroundColour); noteArray.updateNote(userId: appViewModel.currentUserId(), note: note)
                            }
                            .opacity(0.7)
                        TextEditor(text: $note.information)
                            .padding(.top, 0.5)
                            .cornerRadius(4)
                            .lineSpacing(5)
                            .onDebouncedChange(
                                of: $note.information,
                                debounceFor: 1
                            ) { _ in data = note.data; note.update(from: data); note.timestamp = Date();  noteArray.updateNote(userId: appViewModel.currentUserId(), note: note)
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
            }
        }        }
}

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            return "a few seconds ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) mins ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
}

