//
//  Messages.swift
//  Pulse
//
//  Created by Pulse Team
//  Copyright © 2018 Pulse Team. All rights reserved.
//

import Foundation
import Firebase

class Messages {
    
    //Welcome messaage changees based on the current time
    static func getWelcome() -> String {
        //time stuff
        var tod = String()
        switch Calendar.current.component(.hour, from: Date()) {
        case 4..<12:
            tod = "morning"
            break
        case 12..<18:
            tod = "afternoon"
            break
        default:
            tod = "evening"
            break
        }
        
        // return actual
        let m = User.firstName != nil ? ", " + User.firstName! : ""
        return "Good \(tod)\(m). How are you feeling?"
    }
    
    //Pulls time of last log in order to print it on the loggedIn View
    static func getLastLog(_ completion: @escaping (String) -> Void) {
        var m = "N/a"
        guard let uid = Auth.auth().currentUser?.uid else { completion("error"); return }
        if User.lastLog == nil {
            db.document("users/\(uid)/stats/times").getDocument() { (document, error) in
                //check to see if data is in firebase
                if let document = document, document.exists {
                    guard let d = document.data() else { return }
                    if let timeInt = d["lastLogTime"] as? Int {
                        if timeInt < 2 { m = "No logs yet" }
                        let date = Date(timeIntervalSince1970: TimeInterval(Double(timeInt)))
                        User.lastLog = date
                        m = date.englishDateDiffToNow()
                    } else if let timeInt = d["lastLogTime"] as? Double {
                        if timeInt < 2 { m = "No logs yet" }
                        let date = Date(timeIntervalSince1970: TimeInterval(timeInt))
                        User.lastLog = date
                        m = date.englishDateDiffToNow()
                    }
                    completion(m)
                    return
                } else {
                    print("cant find data in firebase")
                }
            }
        } else if User.lastLog?.timeIntervalSince1970 == 0 {
            completion("No logs yet")
        } else {
            guard let d = User.lastLog else { completion("Failed"); return }
            completion(d.englishDateDiffToNow())
        }
    }
    
}
