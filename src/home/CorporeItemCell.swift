//
//  CorporeItemCell.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

class CorporeItemCell: UITableViewCell {

    @IBOutlet weak var thumbinalView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var tagButton:RoundedButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.hg_addBottomBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
    }
    
    
}
