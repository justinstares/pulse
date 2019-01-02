//
//  operations.swift
//  Pulse
//
//  Created by Reilly Freret on 11/12/18.
//  Copyright © 2018 Reilly Freret. All rights reserved.
//

import Foundation

/// Pretty bullshit that Swift doesn't have these built in
func *(_ a: Double, _ b: Int) -> Double {
    return Double(b) * a
}

func *(_ a: Int, _ b: Double) -> Double {
    return Double(a) * b
}
