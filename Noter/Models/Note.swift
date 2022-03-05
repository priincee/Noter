//
//  Note.swift
//  Noter
//
//  Created by Prince Embola on 08/02/2022.
//

import Foundation
import SwiftUI

class Note: Identifiable, ObservableObject {
    var id: UUID
    @Published var title: String
    @Published var information: String
    var nsWindow: NSWindow?
    @Published var timestamp: Date
   
    init(id: UUID = UUID(), nsWindow: NSWindow? = nil, title: String, information: String, timestamp: Date = Date()){
        self.id = id
        self.nsWindow = nsWindow
        self.title = title
        self.information = information
        self.timestamp = timestamp
    }
}

extension Note: Hashable {
    var identifier: UUID {
        return id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Note {
    static var data :  [Note]{
        [
            Note(title: "Design Notes", information: "Test1"),
            
            Note(title: "Test Notes", information: "Test2ssddddddddddfffffffffgffggfgfgfgfgfggfgfgfgfgfgfgfgfgffggffggfgfgfgfgfgffgggfg"),
                      
            Note(title: "App Dev Notes", information: "Test£")
        ]
    }
}

extension Note {
    struct Data {
        var title: String = ""
        var information:  String = ""
        var nsWindow: NSWindow? = nil
    }
    
    var data: Data {
        return Data(title: title, information: information, nsWindow: nsWindow)
    }
    
     func update(from data: Data) {
          title = data.title
          information = data.information
          nsWindow = data.nsWindow
          timestamp = Date()
      }
}
