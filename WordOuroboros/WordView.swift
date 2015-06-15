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
    var word:WordType! {
        didSet {
            if word != nil {
                label.text = word.string
                backgroundColor = word.color
                self.setNeedsUpdateConstraints()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        label.textColor = WOColor.textColor
        label.adjustsFontSizeToFitWidth = true
    }
}
