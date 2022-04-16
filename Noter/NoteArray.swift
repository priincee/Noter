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
    
     func subscribeToChanges() {
         c = notes
             .publisher
             .flatMap { record in record.objectWillChange }
             .sink { [weak self] in
                 self?.objectWillChange.send()
             }
     }
    
    func getData(userId: String,completion: @escaping ()-> Void) {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
    
        let db = Firestore.firestore()
        db.settings = settings
        db.collection("Users").document(userId).collection("Notes").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.notes = snapshot.documents.map { doc in
                            let i = (doc["timestamp"] as? Timestamp)?.seconds
                            return Note(id: UUID(uuidString: doc["id"] as? String ?? "")! ,
                                        title: doc["title"] as? String ?? "",
                                        information: doc["information"] as? String ?? "",
                                        colour: doc["colour"]  as? [String] ?? ["1.0", "1.0", "0.0"],
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
    
    func add(userId: String, note: Note, completion: @escaping ()-> Void) {
        let db = Firestore.firestore()
        db.collection("Users").document(userId).collection("Notes").addDocument(data: ["id": note.id.uuidString, "title":note.title, "information":note.information, "timestamp":note.timestamp]) { error in
            if error == nil {
                self.getData(userId: userId, completion: {
                    self.subscribeToChanges(); completion()
                })
            } else {
                print(error!)
            }
        }
    }
    
    func updateNote(userId: String, note: Note) {
        let db = Firestore.firestore()
        db.collection("Users").document(userId).collection("Notes").whereField("id", isEqualTo: note.id.uuidString).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            db.collection("Users").document(userId).collection("Notes").document(doc.documentID).setData(["title": note.title,"information": note.information,"timestamp": note.timestamp, "colour": note.colour], merge: true)
                        }
                    }
            }
        }
    }
    
    func remove(userId: String, note: Note){
        let db = Firestore.firestore()
        db.collection("Users").document(userId).collection("Notes").whereField("id", isEqualTo: note.id.uuidString).getDocuments { snapshot, error in
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
