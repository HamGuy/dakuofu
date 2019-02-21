//
//  RoundedButton.swift
//  Aspirin
//
//  Created by HamGuy on 7/16/15.
//
//

import UIKit

//@IBDesignable
class RoundedButton: UIButton {
    @IBInspectable var cornerRadius:CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
            clipsToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.5 {
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var normalBgColor: UIColor = UIColor.white{
        didSet{
            backgroundColor = UIColor.clear
            setBackgroundImage(UIImage.imageWithColor(normalBgColor, size: size), for: UIControlState())
            setBackgroundImage(UIImage.imageWithColor(normalBgColor, size: size).imageByApplyingAlpha(0.5), for: .highlighted)
        }
    }
    
    @IBInspectable var disableBgColor: UIColor = UIColor.lightGray{
        didSet{
//            setBackgroundImage(UIImage.imageWithColor(disableBgColor, size: size), forState: .Disabled)
        }
    }
}
