//
//  uiview.swift
//  Pulse
//
//  Created by Reilly Freret on 11/8/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /**
     Adds the full-frame loading animation to a view.
     
     - Important: Use this one only for full-screen loading animations
    */
    func screenLoading() {
        // full loading view
        let loadingView = UIView(frame: self.frame)
        loadingView.tag = 69
        
        // background bouncing circle
        let backgroundAnimation = UIView()
        backgroundAnimation.frame.size = CGSize(width: 100, height: 100)
        backgroundAnimation.layer.cornerRadius = 50
        backgroundAnimation.center = loadingView.center
        backgroundAnimation.backgroundColor = UIColor.Pulse.green
        loadingView.addSubview(backgroundAnimation)
            
        // blur filter
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = loadingView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingView.addSubview(blurEffectView)
        
        // bouncing circle
        let loadingAnimation = UIView()
        loadingAnimation.frame.size = CGSize(width: 100, height: 100)
        loadingAnimation.layer.cornerRadius = 50
        loadingAnimation.center = loadingView.center
        loadingAnimation.backgroundColor = UIColor.Pulse.green
        loadingView.addSubview(loadingAnimation)
        
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            loadingAnimation.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            backgroundAnimation.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            loadingAnimation.backgroundColor = UIColor.Pulse.lightGreen
            backgroundAnimation.backgroundColor = UIColor.Pulse.lightGreen
        })
        self.addSubview(loadingView)
        self.bringSubview(toFront: loadingView)
    }
    
    /**
     Removes a full-frame animation from a view
    */
    func screenLoaded() {
        self.viewWithTag(69)?.removeFromSuperview()
    }
    
    // inspectable variables for setting in StoryBoard
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
    
}
