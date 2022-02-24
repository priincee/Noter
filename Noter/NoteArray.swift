//
//  NoteArray.swift
//  Noter
//
//  Created by Prince Embola on 23/02/2022.
//
import Combine

class NoteArray: ObservableObject, Identifiable {
    @Published var notes = [Note]()
    private var c: AnyCancellable?
    
    init() {
        getData()
        subscribeToChanges()
    }
    
     func subscribeToChanges() {
         c = notes
             .publisher
             .flatMap { record in record.objectWillChange }
             .sink { [weak self] in
                 self?.objectWillChange.send()
             }
     }
    
    func getData() {
        let note1 = Note(title: "Design Notes", information: "Test1")
        let note2 = Note(title: "Test Notes", information: "Test2ssddddddddddfffffffffgffggfgfgfgfgfggfgfgfgfgfgfgfgfgffggffggfgfgfgfgfgffgggfg")
        let note3 = Note(title: "App Dev Notes", information: "Test£")
        
        add(note: note1)
        add(note: note2)
        add(note: note3)
    }
    
    func add(note: Note) {
        notes.append(note)
    }
    
    func remove(note: Note){
        if let index = notes.firstIndex(of: note){
            notes.remove(at: index)
        }
    }
}
