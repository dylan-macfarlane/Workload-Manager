//
//  EventManager2.swift
//  Workload manager
//
//  Created by Dylan MacFarlane on 5/22/20.
//  Copyright © 2020 Dylan MacFarlane. All rights reserved.
//

import Foundation

class EventManager2: ObservableObject {
    
    
    func sendEvent(name: String, date: Date, clas: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d HH:mm:ss Z z y"
        let dateString = dateFormatter.string(from: date)
        let event = NewEvent(Name: name, Date: dateString, Class: clas)
        guard let uploadData = try? JSONEncoder().encode(event) else {
            return
        }
        
        let url = URL(string: "http://localhost/Event")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = uploadData
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
//            if let mimeType = response.mimeType,
//                mimeType == "application/json",
//                let data = data,
//                let dataString = String(data: data, encoding: .utf8) {
//                print ("got data: \(dataString)")
//            }
        }
        task.resume()
    }
    
}
