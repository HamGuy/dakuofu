//
//  UIImage.swift
//  dakuofu
//
//  Created by HamGuy on 9/1/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

extension UIImage{
    class func imageWithColor(_ color:UIColor, size:CGSize) -> UIImage{
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func imageByApplyingAlpha(_ alpha:CGFloat)->UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        context?.setBlendMode(CGBlendMode.multiply)
        context?.setAlpha(alpha)
        context?.draw(self.cgImage!, in: area)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func hg_ResizeImage(size imageSize:CGSize)->UIImage{
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(imageSize, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
}
