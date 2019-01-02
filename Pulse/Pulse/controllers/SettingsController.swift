//
//  SettingsController.swift
//  Pulse
//
//  Created by Pulse Team on 11/13/18.
//  Copyright © 2018 Pulse Team. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class SettingsController: UIViewController {
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.view.screenLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.view.screenLoaded()
                //Push logged out view controlled
                let v = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loggedOut"))
                v.setNavigationBarHidden(true, animated: false)
                UIView.transition(with: ((UIApplication.shared.delegate?.window)!)!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    ((UIApplication.shared.delegate?.window)!)!.rootViewController = v
                }, completion: nil)
                //reset user variables to nil
                User.firstName = nil
                User.lastName = nil
                User.zipCode = nil
                User.totalLogs = nil
                User.lastLog = nil
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    @IBAction func resetPassword(_ sender: Any) {
        
        let user = Auth.auth().currentUser;
        var _: String;
        var email: String;
        email = (user?.email)!;
        var _: String;
        
        //creates allert
        let alert = UIAlertController(title: "Password Reset", message: "Check your email. A password reset link will be sent.", preferredStyle: .alert)
        //adds action to alert
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
            Auth.auth().sendPasswordReset(withEmail: email);
            do {
                try Auth.auth().signOut()
                self.view.screenLoading()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.view.screenLoaded()
                    let v = UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loggedOut"))
                    v.setNavigationBarHidden(true, animated: false)
                    UIView.transition(with: ((UIApplication.shared.delegate?.window)!)!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                        ((UIApplication.shared.delegate?.window)!)!.rootViewController = v
                    }, completion: nil)
                }
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
        }))
        
        //gets return type if you hit cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
