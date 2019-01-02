//
//  User.swift
//  Pulse
//
//  Created by Reilly Freret on 11/9/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import Firebase

struct User: Codable {
    
    static var firstName: String?
    static var lastName: String?
    static var lastLog: Date?
    static var totalLogs: Int?
    static var zipCode: String?
    
    static var id: String? {
        return Auth.auth().currentUser?.uid
    }
    
    /**
     Gets user logs from the specified year and month.
     
     - Parameters:
        - year: an integer representing a year (e.g. 2018)
        - month: an integer representing a month (e.g. 11 for November)
        - completion: a void function whose only parameter is of type [Int: LogDay]?
     
     - Returns: [Int: LogDay]? to completion handler, where Int represents a day of a month and LogDay represents the related LogDay object
    */
    static func moodsFromMonth(_ year: Int, _ month: Int, _ zipCode: String, _ completion: @escaping ([Int: LogDay]?) -> Void) {
        guard let uid = self.id else { return }
        db.collection("users/\(uid)/years/\(year)/months/\(month)/moods").getDocuments() { (querySnapshot, err) in
            if let e = err {
                print(e)
                completion(nil)
            } else {
                var something = [Int: LogDay]()
                for d in querySnapshot!.documents {
                    let day = d.data()["day"] as! Int
                    let value = d.data()["value"] as! Int
                    let interval = d.data()["dateTime"] as! Int
                    let zip = d.data()["zipCode"] as! String
                    let mood = Mood(value, Date(timeIntervalSince1970: TimeInterval(interval)), zip)
                    if something[day] != nil {
                        something[day]!.moods.append(mood)
                    } else {
                        let tempLog = LogDay()
                        tempLog.moods = [mood]
                        something[day] = tempLog
                    }
                }
                completion(something)
            }
        }
    }
    
    /**
     Takes a uid as a String, checks whether related names exist in firebase, and sets the User names if so. Returns true to completion on success.
    */
    static func getNamesFromID(_ id: String, _ completion: @escaping (Bool) -> Void) {
        db.collection("users").document(id).getDocument() { (document, error) in
            if let document = document, document.exists {
                guard let d = document.data() else { return }
                self.firstName = d["firstName"] as? String
                self.lastName = d["lastName"] as? String
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /**
     Populates User.totalLogs and returns its value to completion
     
     - Error codes:
         - (-1): Document (users/<id>/stats/counts) couldn't be found on firebase
         - (-2): Document data() corrupted
         - (-3): Document does not have totalLogs object
    */
    static func totalLogs(_ completion: @escaping (Int) -> Void) {
        if let logs = self.totalLogs {
            completion(logs)
        } else {
            if let id: String = self.id {
                db.document("users/\(id)/stats/counts").getDocument() { (document, error) in
                    if let document = document, document.exists {
                        guard let d = document.data() else { completion(-2); return }
                        if let t = d["totalLogs"] as? Int {
                            self.totalLogs = t
                            completion(t)
                        } else {
                            completion(-3)
                            print("\nNo totallogs found")
                        }
                    } else {
                        completion(-1)
                        print("couldn't find documents somehow?")
                    }
                }
            }
        }
    }
}
