//
//  ToolBar.swift
//  Noter
//
//  Created by Prince Embola on 11/02/2022.
//

import Foundation
import SwiftUI

struct ToolBar: View {
    @Binding var colour: Color
    @Binding var backgroundImage: String
    @State private var windowRef: NSWindow?
    var body: some View{
        HStack{
                ColorPicker("", selection: $colour)
                .accessibilityLabel(Text("Color picker"))
            Button(action: {openBackgroundSelection(background: $backgroundImage)}, label:{
                Image(systemName: "photo")
            }) .buttonStyle(PlainButtonStyle())
               .padding(.trailing, 100)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Change background image"))
        }.padding(.leading,300)
    }
    
    struct ImageSelection: View
    {   @Binding var background: String
        @State var imageList: [String] = ["empty","circleGreen","cube","iltraingle","multicolourtraingle"]
        var body: some View
        {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(imageList, id: \.self) { image in
                        ImageListing(background: $background, image: image)
                            }
                }
            }
        }
    }
    
    struct ImageListing: View
    {
        @Binding var background: String
        @State var image: String
        var body: some View
        {
            Button(action: {background = image}, label:{
                Image(image)
            }) .buttonStyle(PlainButtonStyle())
                .padding()
                .background(Color.clear)
                .cornerRadius(4.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(Color(.gray), lineWidth: 2)
                )  
                .padding(.leading, 5)
                .padding(.trailing, 5)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Select background image"))
        }
    }
    
    func openBackgroundSelection(background: Binding<String>){
        if let curWindow = windowRef {
                   curWindow.makeKeyAndOrderFront(nil)
                   return
               }
           windowRef = NSWindow(
               contentRect: NSRect(x: 0, y: 10, width: 455, height: 150),
               styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
               backing: .buffered, defer: false)
        windowRef?.standardWindowButton(.miniaturizeButton)!.isHidden = true
        windowRef?.standardWindowButton(.zoomButton)!.isHidden = true
        windowRef?.contentView = NSHostingView(rootView: ImageSelection(background: background))
        windowRef?.makeKeyAndOrderFront(nil)
        windowRef?.isReleasedWhenClosed = false
        windowRef = windowRef
   }
}
