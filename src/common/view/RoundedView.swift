//
//  RoundedView.swift
//  Aspirin
//
//  Created by HamGuy on 11/25/15.
//
//

import UIKit

//@IBDesignable
class RoundedView: UIView {
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
}
