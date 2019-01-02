//
//  Mood.swift
//  Pulse
//
//  Created by Reilly Freret on 11/10/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import Firebase

class Mood: Codable {
    
    var value: Int!
    var dateTime: Date!
    var zipCode: String!
    var year: String { return String(Calendar.current.component(.year, from: self.dateTime)) }
    var month: String { return String(Calendar.current.component(.month, from: self.dateTime)) }
    var day: Int { return Calendar.current.component(.day, from: self.dateTime) }
    
    init(_ v: Int, _ d: Date, _ s: String) {
        self.value = v
        self.dateTime = d
        self.zipCode = s
    }
    
    func upload(_ insertCompletion: @escaping (Bool) -> Void, _ updateCompletion: @escaping (Bool) -> Void) {
        // add date to appropriate month document
        let id = Auth.auth().currentUser!.uid
        let collectionPath = "users/\(id)/years/\(self.year)/months/\(self.month)/moods"
        db.collection(collectionPath).addDocument(data: ["value": self.value, "dateTime": lround(self.dateTime.timeIntervalSince1970), "day": self.day, "zipCode": self.zipCode]) { err in
            if err == nil {
                insertCompletion(true)
                
                // update last log for user
                db.document("users/\(id)/stats/times").setData(["lastLogTime": self.dateTime.timeIntervalSince1970])
                User.lastLog = self.dateTime
                
                // update log counter guy
                let updateRef = db.document("users/\(id)/stats/counts")
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let updateDoc: DocumentSnapshot
                    do {
                        try updateDoc = transaction.getDocument(updateRef)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard let prevCount = updateDoc.data()?["totalLogs"] as? Int else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve count from snapshot \(updateDoc)"
                            ]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }
                    
                    transaction.updateData(["totalLogs": prevCount + 1], forDocument: updateRef)
                    if let localTotalLogs = User.totalLogs {
                        User.totalLogs = localTotalLogs + 1
                    }
                    return nil
                }) { (object, error) in
                    if error == nil {
                        updateCompletion(true)
                    } else {
                        updateCompletion(false)
                    }
                }
            } else {
                insertCompletion(false)
            }
        }
        
    }
    
}
