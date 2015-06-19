//
//  AddWordTableViewCell.swift
//  WordOuroboros
//
//  Created by Xplorld on 2015/6/19.
//  Copyright (c) 2015年 Xplorld. All rights reserved.
//

import UIKit

class AddWordTableViewCell: CenterImagedTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tintColor = WOColor.textColor
        self.centerImageView.image = UIImage(named: "plus")?.imageWithRenderingMode(.AlwaysTemplate)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
