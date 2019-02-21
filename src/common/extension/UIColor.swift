//
//  UIColor.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit


extension UIColor{
    convenience init(decRed: CGFloat, decGreen: CGFloat, decBlue: CGFloat) {
        self.init(red: decRed/255.0, green: decGreen/255.0, blue: decBlue/255.0, alpha: 1.0)
    }
    
    convenience init(decRed: CGFloat, decGreen: CGFloat, decBlue: CGFloat, alpha: CGFloat) {
        self.init(red: decRed/255.0, green: decGreen/255.0, blue: decBlue/255.0, alpha: alpha)
    }
    
    func randomColor()->UIColor{
        let r =  CGFloat(drand48())
        let g =  CGFloat(drand48())
        let b =  CGFloat(drand48())
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static var appMainColor: UIColor {
        return UIColor(decRed: 227, decGreen: 83, decBlue: 84)
    }
    
    static var appBackgroundColor: UIColor {
        return UIColor(decRed: 249, decGreen: 249, decBlue: 249)
    }
    
    /// 次要内容,小标题,标签文字等 51 51 51
    static var appMinorColor:UIColor{
        return UIColor(decRed: 51, decGreen: 51, decBlue: 51)
    }
    
    static var appRedColor:UIColor{
        return UIColor(decRed: 230, decGreen: 74, decBlue: 25)
    }
    
    /// 深灰 110 110 110
    static var appGrayColor:UIColor{
        return UIColor(decRed: 110, decGreen: 110, decBlue: 110)
    }
    
    /// Cell 分割线 222 222 222
    static var appContentSeperatorColor:UIColor{
        return UIColor(decRed: 222, decGreen: 222, decBlue: 222)
    }
    
    /// 占位文字颜色 R193 G193 B193
    static var appPlaceholderColor: UIColor {
        return UIColor(decRed: 189, decGreen: 189, decBlue: 189)
    }
    
    static var appPinkColor: UIColor {
        return UIColor(decRed: 255, decGreen: 204, decBlue: 188)
    }
}

