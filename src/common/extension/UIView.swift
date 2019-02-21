//
//  UIView.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import SnapKit

extension UIView {
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin = CGPoint(x: newValue, y: self.frame.origin.y)
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin = CGPoint(x: self.frame.origin.x, y: newValue)
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            self.frame.origin.x = newValue - self.frame.size.width
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set { self.frame.origin.y = newValue }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            self.frame.origin.y = newValue - self.frame.size.height
        }
    }
    
    func removeAllSubviews() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
    
    
    func rounded(cornerRadius radius: CGFloat, borderColor: UIColor? = nil, borderWidth : CGFloat = 0) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if borderColor != nil {
            self.layer.borderColor = borderColor!.cgColor
            self.layer.borderWidth = borderWidth
        }
    }
    
    func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let rect = self.bounds
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath
        
        self.layer.mask = maskLayer
    }
}

extension UIView{
    func hg_addLeftBorder(_ color:UIColor, thickness:CGFloat, sideInset:(top:CGFloat, bottom:CGFloat) = (0,0))->CALayer{
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        border.frame = CGRect(x: 0,y: sideInset.top,width: thickness,height: self.height-(sideInset.top+sideInset.bottom))
        self.layer.addSublayer(border)
        return border
    }
    
    func hg_addTopBorder(_ color:UIColor, thickness:CGFloat,sideInset:(left:CGFloat, right:CGFloat) = (0,0))->CALayer{
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        border.frame = CGRect(x: sideInset.left,y: 0,width: self.width-(sideInset.left+sideInset.right),height: thickness)
        self.layer.addSublayer(border)
        return border
    }
    
    func hg_addRightBorder(_ color:UIColor, thickness:CGFloat, sideInset:(top:CGFloat, bottom:CGFloat) = (0,0))->CALayer{
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        border.frame = CGRect(x: self.width-thickness,y: sideInset.top,width: thickness,height: self.height-(sideInset.top+sideInset.bottom))
        self.layer.addSublayer(border)
        return border
    }
    
    func hg_addBottomBorder(_ color:UIColor, thickness:CGFloat,sideInset:(left:CGFloat, right:CGFloat) = (0,0))->CALayer{
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        border.frame = CGRect(x: sideInset.left,y: self.height-thickness, width: self.width-(sideInset.left+sideInset.right),height: thickness)
        self.layer.addSublayer(border)
        return border
    }
    
    func hg_addSeperatorLine(_ isTop: Bool, color: UIColor) -> UIView {
        return hg_addSeperatorLine(isTop, color: color, leftMargin: 0)
    }
    
    func hg_addSeperatorLine(_ isTop: Bool, color: UIColor, leftMargin: CGFloat) -> UIView {
        let line = UIView(frame: CGRect(x: leftMargin, y: isTop ? 0 : height - 0.5, width: width, height: 0.5))
        line.backgroundColor = color
        line.tag = 10010
        addSubview(line)
        line.snp_makeConstraints { make in
            make.left.equalTo(snp_left).offset(leftMargin)
            make.right.equalTo(snp_right).offset(0)
            if !isTop{
                make.bottom.equalTo(snp_bottom).offset(-0.5)
            } else {
                make.top.equalTo(snp_top).offset(0)
            }
            make.height.equalTo(0.5)
        }
        return line
    }
    
    func hg_addVerticalSeperatorLine(_ leftMargin: CGFloat, color: UIColor) -> UIView {
        let line = UIView(frame: CGRect(x: leftMargin, y: 0, width: 0.5, height: height))
        line.backgroundColor = color
        line.tag = 10011
        self.addSubview(line)
        return line
    }
    
    func hg_removeVerticalSeperatorLine() {
        for subview in subviews {
            if subview.tag == 10011 {
                subview.removeFromSuperview()
            }
        }
    }
}

// MARK: - animation
extension UIView{
    func hg_FadeTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionFade)
    }
}

