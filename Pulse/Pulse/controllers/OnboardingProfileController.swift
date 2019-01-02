//
//  OnboardingProfileController.swift
//  Pulse
//
//  Created by Pulse Team on 11/9/18.
//  Copyright © 2018 Pulse Team. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class OnboardingProfileController: UIViewController {
    
    @IBOutlet var firstNameOutlet: UITextField!
    
    @IBOutlet var lastNameOutlet: UITextField!
   
    @IBAction func firstNext(_ sender: Any) {
        lastNameOutlet.becomeFirstResponder()
    }
    
    @IBAction func secondNext(_ sender: Any) {
        lastNameOutlet.resignFirstResponder()
        addInfoAction(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     Attempts to write a user's full name to firebase
     
     - Dismisses itself on success
     - Presents alert on failure
    */
    @IBAction func addInfoAction(_ sender: Any) {
        let ayo = firstNameOutlet.validateName()
        let lmaoo = lastNameOutlet.validateName()
        if (ayo && lmaoo) {
            self.view.screenLoading()
            db.collection("users").document((Auth.auth().currentUser?.uid)!).setData(["firstName": firstNameOutlet.text!.trimmingCharacters(in: .whitespacesAndNewlines), "lastName": lastNameOutlet.text!.trimmingCharacters(in: .whitespacesAndNewlines)]) { error in
                self.view.screenLoaded()
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Uh-oh!", message: "Something went wrong", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: {_ in self.addInfoAction(self) }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
