//
//  LandingController.swift
//  Pulse
//
//  Created by Reilly Freret on 11/9/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LandingController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    // sets the constraints / params for the landing
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedIn()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        let grad = CAGradientLayer()
        grad.frame = self.view.bounds
        grad.startPoint = CGPoint(x: 0.0, y: 0.0)
        grad.endPoint = CGPoint(x: 1.0, y: 1.0)
        grad.colors = [UIColor.Pulse.green.cgColor, UIColor.Pulse.lightGreen.cgColor]
        self.view.layer.insertSublayer(grad, at: 0)
    }
    
    func checkLoggedIn() {
        if Auth.auth().currentUser != nil {
            //print("\n\n\(u.email)\n")
        } else {
            print("\nno such luck")
        }
    }
}
