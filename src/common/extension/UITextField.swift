//
//  UITextField.swift
//  dakuofu
//
//  Created by HamGuy on 9/7/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

extension UITextField{
    func hg_isTelephone() -> Bool {
        if let _ = text{
            // ^1[3|4|5|7|8][0-9]\d{8}]$
            return text!.isMatch("^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\\d{8}$", options: .caseInsensitive)
        }
        return false
    }
    
    func  hg_isValidatePwd() -> Bool {
        if let _ = text{
            return  6...16 ~= text!.length
        }
        return false
    }
    
    func hg_isValidateAccount(_ minLength: Int = 3 , maxLength: Int = 16) -> Bool{
        if let _ = text{
            return  minLength...maxLength ~= text!.length
        }
        return false
    }
    
    
    func hg_isValidateEmail() -> Bool {
        if let theText = text{
            return theText.isMatch("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        }
        return false
    }
    
}
