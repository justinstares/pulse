//
//  textfield.swift
//  Pulse
//
//  Created by Reilly Freret on 11/8/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    /**
     Formats text field border
     
     - Returns: true if (textfield without whitespaces) is not empty
    */
    func validateName() -> Bool {
        return self.formatBorder(self.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "")
    }
    
    /**
     Formats text field border
     
     - Returns: true if textfield matches pattern <text>@<text>.<text>
    */
    func validateEmail() -> Bool {
        guard let input = self.text else { return false }
        return self.formatBorder((input.matches("[\\S]+@[\\S]+\\.[\\S]")))
    }
    
    /**
     Formats text field border
     
     - Returns: true if textfield has at least 8 characters
    */
    func validatePassword() -> Bool {
        guard let input = self.text else { return false }
        return self.formatBorder(input.count > 7)
    }
    
    func formatBorder(_ good: Bool) -> Bool {
        self.layer.borderColor = good ? UIColor.Pulse.green.cgColor : UIColor.Pulse.red.cgColor
        return good
    }
    
}
