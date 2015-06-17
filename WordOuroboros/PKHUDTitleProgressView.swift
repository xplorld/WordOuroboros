//
//  PKHUDTitleProgressView.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/17.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit
import PKHUD

/// Provides a square view, with a rotating progress image and a title.
@objc public final class PKHUDTitleProgressView: PKHUDImageView {
    public init(title: String?) {
        let image = PKHUDAssets.progressImage
        super.init(image: image)
        commonInit(title)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit("");
    }
    
    private func commonInit(title: String?) {
        titleLabel.text = title
        addSubview(titleLabel)
        
        imageView.layer.addAnimation({
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.toValue = NSNumber(float: 2.0 * Float(M_PI))
            animation.duration = 1.2
            animation.cumulative = true
            animation.repeatCount = Float(INT_MAX)
            return animation
            }(), forKey: "transform.rotation.z")
        imageView.alpha = 0.9
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewWidth: CGFloat = bounds.size.width
        let viewHeight: CGFloat = bounds.size.height
        
        let halfHeight = CGFloat(ceilf(CFloat(viewHeight / 2.0)))
        let quarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0)))
        let threeQuarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0 * 3.0)))
        
        let opticalOffset: CGFloat = 10.0
        
        titleLabel.frame = CGRect(origin: CGPoint(x:0.0, y:opticalOffset), size: CGSize(width: viewWidth, height: quarterHeight))
        imageView.frame = CGRect(origin: CGPoint(x:0.0, y:quarterHeight - opticalOffset), size: CGSize(width: viewWidth, height: threeQuarterHeight))
    }
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(17.0)
        label.textColor = UIColor.blackColor().colorWithAlphaComponent(0.85)
        return label
        }()
}
