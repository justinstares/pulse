//
//  WeatherDay.swift
//  Pulse
//
//  Created by Reilly Freret on 11/11/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation
import UIKit
// weather model , stores information from the api
class Weather: Decodable {
    
    var max_temp: Double!
    var min_temp: Double!
    var data: [weatherData]
    var type: String!
    var imageString: String?
    
    init(l: Double, h: Double, d: [weatherData], t: String) {
        self.max_temp = h
        self.min_temp = l
        self.data = d
        self.type = t
    }
}
