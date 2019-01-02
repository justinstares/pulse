//
//  AppDelegate.swift
//  Pulse
//
//  Created by Team Pulse.
//  Copyright © 2018 Pulse Team. All rights reserved.
// Notification tutorial: https://www.youtube.com/watch?v=e7cTZ4Tp25I


import UIKit
import Firebase
import IQKeyboardManagerSwift
import UserNotifications
import UserNotificationsUI

let db = Firestore.firestore()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    //Month information needed for mood uploading
    var monthData = [Int: LogDay]()
    var currDate = Date()
    var currCal = Calendar.current
    var numDaysInMonth: Int {
        return (currCal.range(of: .day, in: .month, for: currDate)?.count)!
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        //if logged in then push to loggedInController
        if Auth.auth().currentUser != nil {
            let v = UINavigationController(rootViewController: UIStoryboard(name: "LoggedIn", bundle: nil).instantiateViewController(withIdentifier: "loggedIn"))
            v.setNavigationBarHidden(true, animated: false)
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.window?.rootViewController = v
            }, completion: nil)
        }
        
        //Local Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (authorized:Bool, error:Error?) in
            if !authorized {
                print("Did not allow notifications")
            }
        }
        
        //Notification Actions
        
        //1 Define Action
        let sadAction = UNNotificationAction(identifier: "addSad", title: "I'm Feeling Sad", options: [])
        let mehAction = UNNotificationAction(identifier: "addMeh", title: "I'm Feeling Meh", options: [])
        let happyAction = UNNotificationAction(identifier: "addHappy", title: "I'm Feeling Happy", options:[])
        
        //2 Add actions
        let category = UNNotificationCategory(identifier: "addEmotion", actions: [sadAction, mehAction, happyAction], intentIdentifiers: [], options: [])
        
        //3 Add mood to notification framework
        UNUserNotificationCenter.current().setNotificationCategories([category])
        return true
    }
    
    //Creates notification
    func scheduleNotification(){
        
        UNUserNotificationCenter.current().delegate = self
        
        //This sets how often the notification will fire
        //Change repeats to true to have repeating fires
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "How are you feeling?"
        content.body = "Just a reminder to log your mood."
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "addEmotion"
        
        guard let path = Bundle.main.path(forResource: "emotions", ofType: "png") else {return print("cant find image")}
        let url = URL(fileURLWithPath: path)
        do {
            let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
            content.attachments = [attachment]
        }catch{
            print("Attachment could not load")
        }
        
        let request = UNNotificationRequest(identifier: "moodNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error:Error?) in
            if let error = error {
                print("error \(error.localizedDescription)")
            }
        }
        print("reached  end of scheduleNotifdication")
    }
    
    //User input after prompt
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //create mood item
        let m = Mood(0, Date(), "63130")
        
        if response.actionIdentifier == "addSad"{
            print("clicked sad")
            m.value = 0
        }else if response.actionIdentifier == "addMeh"{
            print("clicked meh")
            m.value = 1
        }else{
            print("clicked happy")
            m.value = 2
        }
        //Upload mood to firebase
        m.upload({ b in
            if !b {
                // TODO: alert upload error
            }
        }, { b in
            if b {
                let dayInt = self.currCal.component(.day, from: self.currDate)
                if let d = self.monthData[dayInt] {
                    d.moods.append(m)
                } else {
                    let d = LogDay()
                    d.moods.append(m)
                    self.monthData[dayInt] = d
                }
            } else {
                // TODO: alert update error
            }
        })
        //Actually pushes the notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "key"), object: nil)
        completionHandler()
        scheduleNotification()
    }
    
    //Following code runs when close app (but still running in background)
    func applicationWillEnterForeground(_ application: UIApplication) {
        if Auth.auth().currentUser != nil {
            let v = UINavigationController(rootViewController: UIStoryboard(name: "LoggedIn", bundle: nil).instantiateViewController(withIdentifier: "loggedIn"))
            v.setNavigationBarHidden(true, animated: false)
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.window?.rootViewController = v
            }, completion: nil)
        }
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    //Runs when you close the app
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("closed app")
        scheduleNotification()
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}

