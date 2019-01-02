//
//  LogDay.swift
//  Pulse
//
//  Created by Reilly Freret on 11/11/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import UIKit

class LogDay: Codable {
    
    var moods: [Mood]! = [Mood]()
//    var weather: Weather?
    var steps: Int?
    var avg: Double {
        var avg = Double(0)
        for m: Mood in moods { avg += Double(m.value) }
        return moods.count == 0 ? 0 : (Double(lround(avg * 100.0)) / 100.0) / Double(moods.count)
    }
    
    func color() -> UIColor {
        if moods.count == 0 { return UIColor.lightGray }
        
        // converts the average mood into a transparency value between 0.5 and 1.0
        let c = (lround(avg * 100.0 - 1) * 1.5)
        let scaledAvg = c / 100.0
        let affa = CGFloat((Int(c) % 100) / 2 + 50) / 100.0
        
        switch scaledAvg {
        case 0..<1:
            return UIColor.Pulse.red.withAlphaComponent(1.5 - affa)
        case 1..<2:
            return UIColor.Pulse.yellow.withAlphaComponent(1.5 - affa)
        case 2...4:
            return UIColor.Pulse.green.withAlphaComponent(affa)
        default:
            return UIColor.red
        }
    }
    
}
