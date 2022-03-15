//
//  ContentView.swift
//  Noter
//
//  Created by Prince Embola on 10/10/2021.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseAuth

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

class AppViewModel: ObservableObject {
    let auth = Auth.auth()
    @Published var signedIn = false
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) {[weak self]
            (result, error) in guard result != nil, error == nil else{
                return
            }
            DispatchQueue.main.async{
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) {[weak self]
            (result, error) in guard result != nil, error == nil else {
                return
            }
            let db = Firestore.firestore()
            db.collection("Users").document(result!.user.uid).setData([
                "uid": result!.user.uid
            ])
            DispatchQueue.main.async{
                self?.signedIn = true
            }
        }
    }
    
    func signOut() {
        try? auth.signOut()
        
        self.signedIn = false
    }
    
    func currentUserId() -> String {
        return auth.currentUser!.uid
    }
}

struct SignInOptions: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink("Sign In", destination: SignInView())
                Spacer()
                NavigationLink("Create Account", destination: SignUpView())
            }
            VStack{
                Image("stickNoteLogo").frame(alignment: .topLeading)
                Text("Welcome to Stick Note👋").font(.system(size: 30))
                Text("Sign In or Create an account over there to continue").font(.system(size: 20))
                Text("👈").font(.system(size: 30))
                Spacer()
            }
            
        }
    }
}

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
            VStack {
                Image("stickNoteLogo").frame(alignment: .topLeading)
                Text("Sign In").font(.headline)
                VStack {
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .frame(width: 200, height:30)
                            .cornerRadius(5)
                            .foregroundColor(Color.gray)
                            .opacity(0.3)
                        TextField("Email Address", text: $email)
                            .padding(.leading, 3)
                            .cornerRadius(5)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 200, height: 30)
                    }
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .frame(width: 200, height:30)
                            .cornerRadius(5)
                            .foregroundColor(Color.gray)
                            .opacity(0.3)
                        SecureField("Password", text: $password)
                            .padding(.leading, 3)
                            .cornerRadius(5)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 200, height: 30)
                    }
                    Button(action: { guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                        appViewModel.signIn(email: email, password: password) }, label: {
                        Text("Sign In")
                            .cornerRadius(8)
                    })
                }
            }.padding()
        Spacer()
        }
    }

struct SignUpView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
            VStack {
                Image("stickNoteLogo").frame(alignment: .topLeading)
                Text("Create Account").font(.headline)
                VStack {
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .frame(width: 200, height:30)
                            .cornerRadius(5)
                            .foregroundColor(Color.gray)
                            .opacity(0.3)
                        TextField("Email Address", text: $email)
                            .padding(.leading, 3)
                            .cornerRadius(5)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 200, height: 30)
                    }
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .frame(width: 200, height:30)
                            .cornerRadius(5)
                            .foregroundColor(Color.gray)
                            .opacity(0.3)
                        SecureField("Password", text: $password)
                            .padding(.leading, 3)
                            .cornerRadius(5)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 200, height: 30)
                    }
                    Button(action: { guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                        appViewModel.signUp(email: email, password: password) }, label: {
                        Text("Create Account")
                            .cornerRadius(8)
                    })
                }
            }.padding()
            Spacer()
    }
}

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var noteArray = NoteArray()
    var body: some View {
        VStack {
            if appViewModel.isSignedIn {
                NoteContentView(noteArray: noteArray)
            } else {
                SignInOptions()
            }
        }.onAppear{
            appViewModel.signedIn = appViewModel.isSignedIn
        }
    }
}

struct NoteContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
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
                    NoteListView(note: note, noteArray: noteArray).tag(note)
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
            noteArray.getData(userId: appViewModel.currentUserId(), completion: {noteArray.subscribeToChanges(); selectInitNote()})
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSideBar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
//            ToolbarItem {
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                    TextField("Search", text: $searchString, onEditingChanged: { currentlyEditing in
//                        self.hasFocus = currentlyEditing}).textFieldStyle(.plain)
//                }
//                .padding(.top, 5).padding(.bottom, 5).padding(.trailing, 5).padding(.leading, 5)
//                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).foregroundColor(Color.gray))
//            }
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
            ToolbarItem {
                Menu {
                    Button(action:{appViewModel.signOut()}){
                        Label("Sign Out", systemImage:"person")}
                } label: {
                    Label("Account", systemImage:"person")
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
        noteArray.add(userId: appViewModel.currentUserId(), note: newNote, completion: { selectedNote = noteArray.notes[0]})
        newNoteData = Note.Data()
    }
    
    private func refreshNotes() {
        noteArray.getData(userId: appViewModel.currentUserId(), completion: {noteArray.subscribeToChanges();})
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
        noteArray.remove(userId: appViewModel.currentUserId(),note: note)
    }
    
    var NoNotesView: some View {
        Text("Oops, looks like you have no notes...")
    }

}

