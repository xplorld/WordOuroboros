//
//  ToolBarView.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/11.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

class ToolBarView: UIView {
    
    private var buttons:[UIButton] = []
    var BUTTON_SPACE:CGFloat = 20
    var MARGIN_SPACE:CGFloat = 20
    
    func pushButton(button:UIButton) {
        button.removeFromSuperview()
        self.addSubview(button)
        buttons.append(button)
        self.setNeedsLayout()
    }
    override func layoutSubviews() {
        var x:CGFloat = MARGIN_SPACE
        var y:CGFloat = 0
        
        for button in buttons {
            button.sizeToFit()
            
            //vertically centered
            y = (self.bounds.height - button.frame.height) / 2
            
            button.frame.origin = CGPoint(x: x, y: y)
            
            x += button.frame.width
            x += BUTTON_SPACE
        }

    }
    
}
