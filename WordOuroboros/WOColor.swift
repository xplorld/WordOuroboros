//
//  WOColor.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

struct WOColor {
    //flat ui colors
    //http://flatuicolors.com/
    static let colors:[UIColor] = [0x1abc9c,0x2ecc71,0x4aa3df,0x9b59b6,0x16a085,0x27ae60,0x2980b9,0x8e44ad,0xf1c40f,0xe67e22,0xe74c3c,0xecf0f1,0x95a5a6,0xf39c12,0xd35400,0xc0392b,0xbdc3c7,0xa7f8c8d].map {
        UIColor.hexToUIColor($0)
    }
    static private var prevIndex = 0
    static func getColor() -> UIColor {
        prevIndex = ( prevIndex + 1 ) % colors.count
        return colors[prevIndex]
    }
    
}
//from hex
extension UIColor {
    class func hexToUIColor(hex:UInt32) -> UIColor {
        
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}