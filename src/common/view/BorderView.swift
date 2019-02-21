//
//  BorderView.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

class  BorderView: UIView {
    @IBInspectable var bottomBorderColor: UIColor = UIColor.clear
    
    override func layoutSubviews(){
        super.layoutSubviews()
        self.hg_addBottomBorder(bottomBorderColor, thickness: 0.5)
    }
}
