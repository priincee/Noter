//
//  NewNoteView.swift
//  Noter
//
//  Created by Prince Embola on 18/02/2022.
//

import Foundation
import SwiftUI

struct NewNoteView: View {
    @Binding var noteData: Note.Data
    var body: some View {
            VStack(){
                Text("New Note")
                    .font( .headline)
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .border(Color.gray, width: 1.5)
                        .frame(width: .infinity, height:25)
                        .foregroundColor(Color.white)
                        .opacity(0.1)
                    if noteData.title.isEmpty {
                                  Text("Enter Title Here")
                            .foregroundColor(Color(.gray))
                                      .padding(.horizontal, 8)
                                      .padding(.vertical, 12)
                              }
                    TextEditor(text: $noteData.title)
                        .padding(.top, 3)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.headline)
                        .frame(height: 25)
                        .cornerRadius(5)
                }
                ZStack(alignment: .center){ RoundedRectangle(cornerRadius: 5,style: .continuous)
                        .border(Color.gray, width: 1.5)
                        .foregroundColor(Color.white)
                        .opacity(0.1)
                    if noteData.information.isEmpty {
                                  Text("Enter Note Here")
                            .foregroundColor(Color(.gray))
                                      .padding(.horizontal, 8)
                                      .padding(.vertical, 12)
                              }
                    TextEditor(text: $noteData.information)
                        .padding(.top, 3)
                        .cornerRadius(5)
                        .lineSpacing(5)
                }
            }
        .padding()
    }
}
