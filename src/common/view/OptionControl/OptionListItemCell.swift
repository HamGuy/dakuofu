//
//  OptionListItemCell.swift
//  dakuofu
//
//  Created by HamGuy on 9/2/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

class OptionListItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var checkMark:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = { view in
            view.backgroundColor = UIColor.white
            return view
        }(UIView())
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.hg_addBottomBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
        selectedBackgroundView?.hg_addTopBorder(UIColor.appContentSeperatorColor, thickness: 0.5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
        self.titleLabel.textColor = selected ? UIColor.appMainColor : UIColor.appMinorColor
        self.checkMark.isHidden = !selected
    }
}
