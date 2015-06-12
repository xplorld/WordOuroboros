//
//  WordView.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/10.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

class WordView: UIView {
    
    @IBOutlet var label:UILabel!
    var text:String {
        get {
            return label.text ?? ""
        }
        set {
            label.text = newValue
        }
    }
}
