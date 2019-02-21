//
//  UITableViewCell.swift
//  dakuofu
//
//  Created by HamGuy on 9/2/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

extension UITableViewCell{
    class func nib() -> UINib{
        return UINib(nibName:  NSStringFromClass(self).components(separatedBy: ".").last!, bundle:  Bundle.main)
    }
    
    class func reuseIdentifier(_ customString:String? = nil)->String{
        var result = "kHG" + NSStringFromClass(self).components(separatedBy: ".").last!
        if let string = customString{
            result += string
        }
        return result
    }
}

