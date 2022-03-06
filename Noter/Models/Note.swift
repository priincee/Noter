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
    var colour: [String]
    var nsWindow: NSWindow?
    @Published var timestamp: Date
   
    init(id: UUID = UUID(), nsWindow: NSWindow? = nil, title: String, information: String, colour: [String] = ["1.0", "1.0", "0.0"], timestamp: Date = Date()){
        self.id = id
        self.nsWindow = nsWindow
        self.title = title
        self.information = information
        self.timestamp = timestamp
        self.colour = colour
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
    struct Data {
        var title: String = ""
        var information:  String = ""
        var nsWindow: NSWindow? = nil
        var colour: [String] = []
    }
    
    var data: Data {
        return Data(title: title, information: information, nsWindow: nsWindow, colour: colour)
    }
    
     func update(from data: Data) {
        title = data.title
        information = data.information
        colour = data.colour
        nsWindow = data.nsWindow
        timestamp = Date()
        
      }
    func updateColourFromPicker(color: Color) {
           let colorString = "\(color)"
           let colorArray: [String] = colorString.components(separatedBy: " ")
            
        let r: CGFloat = CGFloat(Float(colorArray[3]) ?? 1)
        let b: CGFloat = CGFloat(Float(colorArray[4]) ?? 1)
        let g: CGFloat = CGFloat(Float(colorArray[5]) ?? 1)
        print(r)
        print(g)
        print(b)
        colour[0] = colorArray[3]
        colour[1] = colorArray[4]
        colour[2] = colorArray[5]
       }
}
