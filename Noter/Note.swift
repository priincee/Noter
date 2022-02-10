//
//  Note.swift
//  Noter
//
//  Created by Prince Embola on 08/02/2022.
//

import Foundation
import SwiftUI

struct Note: Identifiable {
    var id: UUID
    var title: String
    var information: String
    var timestamp: Date
   
    init(id: UUID = UUID(), title: String, information: String, timestamp: Date = Date()){
        self.id = id
        self.title = title
        self.information = information
        self.timestamp = timestamp
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

extension Note{
    struct Data{
        var title: String = ""
        var information:  String = ""
    }
    
    var data: Data {
        return Data(title: title, information: information)
    }
    
    mutating func update(from data: Data) {
          title = data.title
          information = data.information
          timestamp = Date()
      }
}
