//
//  FloatMenuItem.swift
//  dakuofu
//
//  Created by HamGuy on 9/19/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

typealias ButtonClickBlock = (_ index: Int, _ sender: UIButton) -> Void

class FloatMenuItem: UIButton {
    
    var clickedBlock: ButtonClickBlock?
    
    init(backgroundImage: UIImage?, highlightImage: UIImage?, clickedBlock: ButtonClickBlock?) {
        
        guard let nonNilBackgroundImage = backgroundImage else {
            fatalError("ERROR, image can not be nil")
        }
        
        let buttonFrame = CGRect(x: 0, y: 0, width: nonNilBackgroundImage.size.width, height: nonNilBackgroundImage.size.height)
        super.init(frame: buttonFrame)
        self.setBackgroundImage(nonNilBackgroundImage, for: UIControlState())
        
        if let nonNilHighlightImage = highlightImage {
            self.setBackgroundImage(nonNilHighlightImage, for: .highlighted)
        }
        
        self.clickedBlock = clickedBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
