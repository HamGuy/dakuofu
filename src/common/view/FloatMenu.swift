//
//  FloatMenu.swift
//  dakuofu
//
//  Created by HamGuy on 9/19/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

let π = CGFloat(M_PI)

enum ExpendDirection {
    case top
    case bottom
    case left
    case right
    case leftUp
    case leftDown
    case rightUp
    case rightDown
}

enum FloatMenuMode {
    case sickle
    case flower
}

enum PositionMode {
    case fixed
    case touchBorder
}

class FloatMenu: UIView {
    
    fileprivate static let sickleSpreadAngleDefault: CGFloat = 90.0
    fileprivate static let flowerSpreadAngleDefault: CGFloat = 120.0
    fileprivate static let spredaDirectionDefault: ExpendDirection = .top
    fileprivate static let spreadRadiusDefault: CGFloat = 100.0
    fileprivate static let coverAlphaDefault: CGFloat = 0.1
    fileprivate static let touchBorderMarginDefault: CGFloat = 10.0
    fileprivate static let touchBorderAnimationDuringDefault = 0.5
    fileprivate static let animationDuringDefault = 0.2
    
    //During
    var animationDuring = animationDuringDefault {
        didSet {
            animationDuringSpread = animationDuring
            animationDuringClose = animationDuring
        }
    }
    var animationDuringSpread = animationDuringDefault
    var animationDuringClose = animationDuringDefault
    
    var coverAlpha: CGFloat = coverAlphaDefault
    var coverColor: UIColor {
        set { cover.backgroundColor = newValue }
        get { return cover.backgroundColor! }
    }
    
    var mode: FloatMenuMode = .sickle
    var positionMode: PositionMode = .fixed
    
    var radius: CGFloat = spreadRadiusDefault
    
    var direction: ExpendDirection = spredaDirectionDefault {
        didSet {
            if direction == .top || direction == .left || direction == .right || direction == .bottom {
                spreadAngle = FloatMenu.flowerSpreadAngleDefault
            } else {
                spreadAngle = FloatMenu.sickleSpreadAngleDefault
            }
        }
    }
    
    var touchBorderMargin: CGFloat = touchBorderMarginDefault
    
    
    fileprivate var subButtons: [FloatMenuItem]?
    fileprivate let defaultCoverColor = UIColor.clear
    
    fileprivate var powerButton: UIButton!
    
    fileprivate var cover: UIView!
    
    fileprivate var animator: UIDynamicAnimator!
    
    fileprivate var mainFrame: CGRect!
    
    fileprivate var powerButtonPosition: CGPoint {//记录Power相对于super的位置，还没展开时，就是 FloatMenu 的位置
        get { return isSpread ? self.powerButton.center : self.center }
        set {
            self.center = newValue
            superViewRelativePosition = newValue
        }
    }
    
    fileprivate var isSpread = false
    
    fileprivate var superViewRelativePosition: CGPoint!//记录展开按钮相对于super的位置
    
    fileprivate var spreadAngle: CGFloat = flowerSpreadAngleDefault
    
    
    
    init(image: UIImage?, highlightImage: UIImage?, position: CGPoint) {
        guard let nonNilImage = image else {
            fatalError("ERROR, image can not be nil")
        }
        
        let mainFrame = CGRect(x: position.x, y: position.y, width: nonNilImage.size.width, height: nonNilImage.size.height)
        super.init(frame: mainFrame)
        
        //save the mainFrame
        self.mainFrame = mainFrame
        self.powerButtonPosition = position
        
        configureGesture()
        configureMainButton(nonNilImage, highlightImage: highlightImage)
        configureCover()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMainButton(_ image: UIImage, highlightImage: UIImage?) {
        powerButton = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        //初始位置
        powerButton.setBackgroundImage(image, for: UIControlState())
        if let nonNilhighlightImage = highlightImage {
            powerButton.setBackgroundImage(nonNilhighlightImage, for: .highlighted)
        }
        powerButton.addTarget(self, action: #selector(tapPowerButton(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(powerButton)
    }
    
    func configureCover() {
        cover = UIView(frame: self.bounds)
        cover.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cover.isUserInteractionEnabled = true
        cover.backgroundColor = defaultCoverColor
        cover.alpha = 0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCover))
        cover.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configureGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panFloatMenu(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func tapPowerButton(_ button: UIButton) {
        isSpread ? closeButton(nil) : expendMenu()
    }
    
    func tapCover() {
        if isSpread {
            closeButton(nil)
        }
    }
    
    func panFloatMenu(_ gesture: UIPanGestureRecognizer) {
        //drag the powerButton
        if isSpread {
            return
        }
        switch gesture.state {
        case .began:
            animator.removeAllBehaviors()
        case .ended:
            switch positionMode {
            case .fixed:
                let snapBehavior = UISnapBehavior(item: self, snapTo: superViewRelativePosition)
                snapBehavior.damping = 0.5
                animator.addBehavior(snapBehavior)
            case .touchBorder:
                let location = gesture.location(in: self.superview)
                var destinationLocation: CGPoint
                
                if location.y < 90 {//上面
                    destinationLocation = CGPoint(x: location.x, y: self.bounds.width/2 + touchBorderMargin)
                } else if location.y > UIScreen.main.bounds.height - 90 {//下面
                    destinationLocation = CGPoint(x: location.x, y: UIScreen.main.bounds.height - self.bounds.height/2 - touchBorderMargin)
                } else if location.x > UIScreen.main.bounds.width/2 {//右边
                    destinationLocation = CGPoint(x: UIScreen.main.bounds.width - (self.bounds.width/2 + touchBorderMargin), y: location.y)
                } else {//左边
                    destinationLocation = CGPoint(x: self.bounds.width/2 + touchBorderMargin, y: location.y)
                }
                
                let touchBorderAnimation = CABasicAnimation(keyPath: "position")
                touchBorderAnimation.delegate = self
                touchBorderAnimation.isRemovedOnCompletion = false
                touchBorderAnimation.fromValue = location as? AnyObject
                touchBorderAnimation.toValue = destinationLocation as? AnyObject
                touchBorderAnimation.duration = FloatMenu.touchBorderAnimationDuringDefault
                touchBorderAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.layer.add(touchBorderAnimation, forKey: "touchBorder")
                
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                self.center = destinationLocation
                CATransaction.commit()
            }
            
        default:
            let location = gesture.location(in: self.superview)
            self.center = location
        }
    }
    
    //展开按钮
    func expendMenu() {
        guard subButtons != nil else {
            print("subButton can not be nil")
            return
        }
        animator.removeAllBehaviors()
        isSpread = true
        
        //改变frame, 充满superView
        if (superview != nil) {
            frame = (superview?.bounds)!
        }
        //position powerButton
        powerButton.center = superViewRelativePosition
        
        //insert cover
        self.insertSubview(cover, belowSubview: powerButton)
        
        //cover animation
        UIView.animate(withDuration: animationDuringSpread, animations: { () -> Void in
            self.cover.alpha = self.coverAlpha
            self.powerButtonRotationAnimate()
        }) 
        //按钮展开
        expendSubButton()
    }
    
    //子按钮展开动作
    func expendSubButton() {
        let subButtonCrackAngle = spreadAngle / CGFloat(subButtons!.count - 1)
        //startAngle
        var angle: CGFloat
        let startSpace: CGFloat = (180 - spreadAngle)/2
        
        switch direction {
        case .top:
            angle = startSpace
        case .bottom:
            angle = -180 + startSpace
        case .left:
            angle = 90 + startSpace
        case .right:
            angle = -90 + startSpace
        case .leftUp:
            angle = 90
        case .leftDown:
            angle = 180
        case .rightUp:
            angle = 0
        case .rightDown:
            angle = -90
        }
        
        var startOutSidePoint: CGPoint!
        var startAngle: CGFloat!
        for btn in self.subButtons! {
            btn.transform = CGAffineTransform(translationX: 1.0, y: 1.0)
            self.insertSubview(btn, belowSubview: powerButton)
            btn.alpha = 1.0
            btn.center = powerButton.center
            
            let btnIndex = subButtons?.index(of: btn)
            if btnIndex == 0 {
                startOutSidePoint = calculatePoint(angle, radius: radius)
                startAngle = angle
            }
            
            let outsidePoint = calculatePoint(angle, radius: radius)
            let shockOutsidePoint = calculatePoint(angle, radius: radius + 10)
            let shockInsidePoint = calculatePoint(angle, radius: radius - 3)
            
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            var animationPath: UIBezierPath!
            
            switch mode {
            case .sickle:
                if direction == .top || direction == .bottom || direction == .left || direction == .right {
                    //---It does not provide SickleSpread in those four directions---
                    animationPath = movingPath(btn.layer.position, keyPoints: shockOutsidePoint, shockInsidePoint, outsidePoint)
                    positionAnimation.keyTimes = [0.0, 0.8, 0.93, 1.0]
                    positionAnimation.duration = animationDuringSpread
                } else {
                    if btnIndex == 0 {
                        animationPath = movingPath(btn.layer.position, keyPoints: startOutSidePoint)
                        positionAnimation.keyTimes = [0.0, 0.2]
                    } else if btnIndex != ((subButtons?.count)! - 1) {
                        animationPath = movingPath(btn.layer.position, endPoint: startOutSidePoint, startAngle: startAngle/180*π, endAngle: angle/180*π, center: btn.layer.position)
                        positionAnimation.keyTimes = [0.0, 0.2,    0.3, 1.0]
                    }
                    else {
                        animationPath = movingPath(btn.layer.position, endPoint: startOutSidePoint, startAngle: startAngle/180*π, endAngle: angle/180*π, center: btn.layer.position, shock: true)
                        positionAnimation.keyTimes = [0.0, 0.2,    0.3, 0.9,    0.9, 0.95,   0.95, 1.0]
                    }
                    positionAnimation.duration = animationDuringSpread*(1+0.2*Double((btnIndex?.hashValue)!))
                }
            case .flower:
                animationPath = movingPath(btn.layer.position, keyPoints: shockOutsidePoint, shockInsidePoint, outsidePoint)
                positionAnimation.keyTimes = [0.0, 0.8, 0.93, 1.0]
                positionAnimation.duration = animationDuringSpread
            }
            positionAnimation.path = animationPath.cgPath
            btn.layer.add(positionAnimation, forKey: "sickleSpread")
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            btn.layer.position = outsidePoint
            CATransaction.commit()
            
            angle += subButtonCrackAngle
        }
    }
    
    
    func closeButton(_ exclusiveBtn: FloatMenuItem?) {
        isSpread = false
        
        //cover animation
        UIView.animate(withDuration: animationDuringClose, animations: { () -> Void in
            self.cover.alpha = 0
            self.powerButtonCloseAnimate()
        }, completion: { (flag) -> Void in
            self.cover.removeFromSuperview()
            self.frame = self.powerButton.frame
            self.powerButton.frame = self.bounds
        }) 
        
        closeSubButton(exclusiveBtn)
    }
    
    func closeSubButton(_ exclusiveBtn: FloatMenuItem?) {
        for btn in subButtons! {
            if exclusiveBtn != nil {
                if btn != exclusiveBtn {
                    btn.removeFromSuperview()
                }
                continue
            }
            
            let animationPath = movingPath(btn.layer.position, keyPoints: powerButton.layer.position)
            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.path = animationPath.cgPath
            //TODO这里错了。。times?
            positionAnimation.values = [0.0, 1.0]
            positionAnimation.duration = animationDuringClose
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.0
            alphaAnimation.duration = animationDuringClose
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)

            let dismissGroupAnimation = CAAnimationGroup()
            dismissGroupAnimation.animations = [alphaAnimation, positionAnimation]
            dismissGroupAnimation.duration = animationDuringClose
            
            btn.layer.add(dismissGroupAnimation, forKey: "close")
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            btn.frame = CGRect(x: 0, y: 0, width: btn.bounds.width, height: btn.bounds.height)
            btn.alpha = 0
            CATransaction.commit()
        }
        
        if let nonNilExclusiveBtn = exclusiveBtn {
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.0
            alphaAnimation.duration = animationDuringClose
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 3.0
            scaleAnimation.duration = animationDuringClose
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            
            let dismissGroupAnimation = CAAnimationGroup()
            dismissGroupAnimation.animations = [alphaAnimation, scaleAnimation]
            dismissGroupAnimation.duration = animationDuringClose
            
            nonNilExclusiveBtn.layer.add(dismissGroupAnimation, forKey: "closeGroup")
            
            CATransaction.begin()
            //设置kCATransactionDisableActions的valu为true, 来禁用layer的implicit animations
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            nonNilExclusiveBtn.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            nonNilExclusiveBtn.layer.opacity = 0.0
            CATransaction.commit()
            
        }
    }
    
    
    func calculatePoint(_ angle: CGFloat, radius: CGFloat) -> CGPoint {
        //根据弧度和半径计算点的位置
        //center => powerButton
        return CGPoint(x: powerButton.center.x + cos(angle/180.0 * π) * radius, y: powerButton.center.y - sin(angle/180.0 * π) * radius)
    }
    
    //移动路径
    func movingPath(_ startPoint: CGPoint, keyPoints: CGPoint...) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: startPoint)
        for point in keyPoints {
            path.addLine(to: point)
        }
        return path
    }
    
    func movingPath(_ startPoint: CGPoint, endPoint: CGPoint, startAngle: CGFloat, endAngle: CGFloat, center: CGPoint, shock: Bool = false) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        if shock {
            path.addArc(withCenter: center, radius: radius, startAngle: -startAngle, endAngle: -endAngle - 3/180*π, clockwise: false)
            path.addArc(withCenter: center, radius: radius, startAngle: -endAngle - 3/180*π, endAngle: -endAngle + 1/180*π, clockwise: true)
            path.addArc(withCenter: center, radius: radius, startAngle: -endAngle + 1/180*π, endAngle: -endAngle, clockwise: false)
        } else {
            path.addArc(withCenter: center, radius: radius, startAngle: -startAngle, endAngle: -endAngle, clockwise: false)
        }
        
        return path
    }
    
    func changeSpreadDirection() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerAreaWidth = screenWidth - 2 * radius
        let location = self.center
        //改变Spreading的位置
        superViewRelativePosition = location
        
        if location.x < screenWidth/2 - centerAreaWidth/2 {//左边
            switch location.y {
            case 0..<radius:
                direction = .rightDown
            case radius..<(screenHeight - radius):
                direction = .right
            case (screenHeight - radius)..<screenHeight:
                direction = .rightUp
            default: break
            }
        } else if location.x > screenWidth/2 + centerAreaWidth/2 {//右边
            switch location.y {
            case 0..<radius:
                direction = .leftDown
            case radius..<(screenHeight - radius):
                direction = .left
            case (screenHeight - radius)..<screenHeight:
                direction = .leftUp
            default: break
            }
        } else {//中间
            if location.y < screenHeight/2 {
                direction = .bottom
            } else {
                direction = .top
            }
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        cover.frame = (newSuperview?.bounds)!
    }
    
    override func didMoveToSuperview() {
        animator = UIDynamicAnimator(referenceView: self.superview!)
    }
    
    func powerButtonRotationAnimate() {
        powerButton.transform = CGAffineTransform(rotationAngle: CGFloat(-0.75 * π))
    }
    
    func powerButtonCloseAnimate() {
        powerButton.transform = CGAffineTransform(rotationAngle: 0)
    }
    
    //setter
    func setSubButtons(_ buttons: [FloatMenuItem]) {
        _ = buttons.flatMap { ($0 as FloatMenuItem).addTarget(self, action: #selector(clickedSubButton(_:)), for: .touchUpInside) }
        let nonNilButtons = buttons.flatMap { $0 }
        subButtons = Array<FloatMenuItem>()
        subButtons?.append(contentsOf: nonNilButtons)
    }
    
    func clickedSubButton(_ sender: FloatMenuItem) {
        closeButton(sender)
        let index = subButtons?.index(of: sender)
        if let nonNilIndex = index {
            sender.clickedBlock?(nonNilIndex, sender)
        }
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let touchBorderAnim = self.layer.animation(forKey: "touchBorder")
        if touchBorderAnim == anim {
            changeSpreadDirection()
        }
    }
    
}