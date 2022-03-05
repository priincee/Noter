//
//  NoteArray.swift
//  Noter
//
//  Created by Prince Embola on 23/02/2022.
//
import Combine
import Firebase
import SwiftUI

class NoteArray: ObservableObject, Identifiable {
    @Published var notes = [Note]()
    private var c: AnyCancellable?
    
    init() {
        
    }
    
     func subscribeToChanges() {
         c = notes
             .publisher
             .flatMap { record in record.objectWillChange }
             .sink { [weak self] in
                 self?.objectWillChange.send()
             }
     }
    
    func getData(completion: @escaping ()-> Void) {
        let db = Firestore.firestore()
        db.collection("Notes").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.notes = snapshot.documents.map { doc in
                            let i = (doc["timestamp"] as? Timestamp)?.seconds
                            return Note(id: UUID(uuidString: doc["id"] as? String ?? "")! ,
                                        title: doc["title"] as? String ?? "",
                                        information: doc["information"] as? String ?? "",
                                        timestamp: Date(timeIntervalSince1970: TimeInterval(i!)))
                        }
                        completion()
                    }
                }
            } else {
                print(error!)
            }
        }
    }
    
    func add(note: Note, completion: @escaping ()-> Void) {
        let db = Firestore.firestore()
        db.collection("Notes").addDocument(data: ["id": note.id.uuidString, "title":note.title, "information":note.information, "timestamp":note.timestamp]) { error in
            if error == nil {
                self.getData(completion: { print("i got callled");
                    self.subscribeToChanges(); completion()
                })
            } else {
                print(error!)
            }
        }
    }
    
    func updateNote(note: Note) {
        let db = Firestore.firestore()
        db.collection("Notes").whereField("id", isEqualTo: note.id.uuidString).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            db.collection("Notes").document(doc.documentID).setData(["title": note.title,"information": note.information,"timestamp": note.timestamp], merge: true)
                        }
                    }
            }
        }
    }
    
    func remove(note: Note){
        let db = Firestore.firestore()
        db.collection("Notes").whereField("id", isEqualTo: note.id.uuidString).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        for doc in snapshot.documents {
                            doc.reference.delete()
                            if let index = self.notes.firstIndex(of: note){
                                self.notes.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
    }
}
