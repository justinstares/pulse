//
//  DayView.swift
//  Pulse
//
//  Created by Reilly Freret on 11/14/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import UIKit

class DayView: UIView {
    
    init(logDay: LogDay) {
        super.init(frame: CGRect())
        self.center = (superview?.center)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
