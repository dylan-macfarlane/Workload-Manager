//
//  EventManager.swift
//  Workload manager
//
//  Created by Dylan MacFarlane on 5/22/20.
//  Copyright © 2020 Dylan MacFarlane. All rights reserved.
//

import Foundation


class EventManager: ObservableObject {
    
    var names = [""]
    var dates = [""]
    var classes = [""]
    @Published var events = ["                                                                                   "]
    @Published var eventCount: Int = 0
    var fevents: [String] = []
    
    
    
    func fetchClass(nameResult: String) {
        let formattedName = nameResult.replacingOccurrences(of: " ", with: "%20")
        let eurl = "http://localhost/Class/\(formattedName)"
        fetch(urlString: eurl)
    }
    
    func fetch(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let eventData = try decoder.decode(EventData.self, from: safeData)
                            self.names = eventData.Names
                            print(self.names)
                            self.dates = eventData.Dates
                            self.classes = eventData.Classes
                            
                            var i = 0
                            
                            for _ in self.names {
                                print(self.names[i])
                                self.fevents.append("")
                                self.fevents[i] = "\(self.names[i]) - \(self.dates[i]) - \(self.classes[i])"
                                print("Events: \(self.fevents)")
                                i += 1
                            }
                            self.events = self.fevents
                            self.eventCount = self.events.count
                            
                        } catch {
                            print(error)
                        }
                    }
                }
                
            }
            task.resume()
        }
        
    }
}
