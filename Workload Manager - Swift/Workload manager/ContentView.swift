//
//  ContentView.swift
//  Workload manager
//
//  Created by Dylan MacFarlane on 5/11/20.
//  Copyright © 2020 Dylan MacFarlane. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
//    @State var testEvents = ["T1 - Mon May 12 05:05:05 +7000 PDT 2020 - Math 50 (F)", "Math 40", "Math 30"]
    
    @State var eventName = ""
    @State var eventClass = ""
    @State var eventDate = Date()
    @State var nameResult = ""
    let classes = ["Math 50 (F)", "French 2 (C)", "BVFB", "Honors Chemistry (B)"]
    @State private var select1 = 0
    @State private var select2 = 0
    
    @ObservedObject var eventManager = EventManager()
    @ObservedObject var eventManager2 = EventManager2()
 
    var body: some View {
        TabView(selection: $selection){
            VStack{
                Text("New Commitment")
                    .fontWeight(.heavy)
                    .font(.system(size: 36))
                    .padding(19.0)
                Picker(selection: $select1, label: Text("Class")) {
                    Text("Math 50 (F)").tag(0)
                    Text("French 2 (C)").tag(1)
                    Text("BVFB").tag(2)
                    Text("Honors Chemistry (B)").tag(3)
                }
            .padding()
                TextField("Name:", text: $eventName)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.gray)
                            .opacity(0.3)
                )
                    .padding(8)
                DatePicker(selection: $eventDate, label: { Text("Date") })
                    .padding()
                Button(action: {
                    if self.eventName != "" {
                        print("select1 = \(self.select1)")
                        self.eventClass = self.classes[self.select1]
                        print("event Class = \(self.eventClass)")
                        self.eventManager2.sendEvent(name: self.eventName, date: self.eventDate, clas: self.eventClass)
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.gray)
                            .opacity(0.3)
                            .padding()
                        Text("Enter")
                            .foregroundColor(.black)
                            .fontWeight(.heavy)
                    }
                }

            }
                .background(Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            )
                
                .tabItem {
                    VStack {
                        Image("first")
                        Text("Input")
                    }
                }
                .tag(0)
            VStack {
                VStack {
                    Picker(selection: $select2, label: Text("Class:")) {
                        Text("Math 50 (F)").tag(0)
                        Text("French 2 (C)").tag(1)
                        Text("BVFB").tag(2)
                        Text("Honors Chemistry (B)").tag(3)
                    }
                    .padding()
                    Button(action: {
                        self.nameResult = self.classes[self.select2]
                        self.eventManager.fetchClass(nameResult: self.nameResult)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.gray)
                                .opacity(0.30)
                            Text("Find Commitments")
                                .foregroundColor(.black)
                                .fontWeight(.heavy)
                                
                        }
                        
                    }
                    .padding()
                }
                
                ScrollView {
                    ForEach(eventManager.events, id: \.self) { events in
                        Text(events)
                        .padding()
                        .background(
                        RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                        .opacity(0.30)
                        )
                        .padding()
                    }
                }
            }
                .background(Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                )
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Calendar")
                    }
                }
                .tag(1)
        }

    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
