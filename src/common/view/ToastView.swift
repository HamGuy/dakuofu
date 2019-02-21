//
//  ToastView.swift
//  Aspirin
//
//  Created by HamGuy on 8/30/16.
//
//

import UIKit


/// 弱提示
class ToastView: NSObject {
    fileprivate var containerView: UIButton
    dynamic var backgroundColor: UIColor = UIColor(decRed: 51, decGreen: 51, decBlue: 51, alpha: 0.75)
    dynamic var duration: CGFloat = 2.0
    dynamic var font = UIFont.boldSystemFont(ofSize: 16)
    dynamic var textColor = UIColor.white
    dynamic var offset: CGFloat = 120.0

    enum ToatPosition: Int{
        case center
        case top
        case bottom
    }
    
    fileprivate init(text: String){
        let attributes = [NSFontAttributeName: font]
        let rect = text.boundingRect(with: CGSize(width: 250,height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes:attributes, context: nil)
        containerView = UIButton(frame: CGRect(x: 0, y: 0, width: rect.size.width + 40, height: rect.size.height + 20))
        containerView.layer.cornerRadius = 20.0
        containerView.backgroundColor = backgroundColor
        containerView.titleLabel?.numberOfLines = 0
        containerView.titleLabel?.font = font
        containerView.titleLabel?.textColor = textColor
        containerView.titleLabel?.backgroundColor = UIColor.clear
        containerView .setTitle(text, for: UIControlState())
        containerView.setTitle(text, for: .highlighted)
        containerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        containerView.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        containerView.alpha = 0.0
        super.init()
    }
    
    @IBAction func tapToast(_ btn:UIButton){
        
    }
}

extension ToastView{
    fileprivate func dismissToast() {
        containerView.removeFromSuperview()
    }
    
    fileprivate func showAnimation() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.containerView.alpha = 1.0
            
        }) { completion in
            
            
        }
    }
    
    fileprivate  func hideAnimation() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.containerView.alpha = 0.0
            
        }) { completion in
            
            self.dismissToast()
        }
        
    }
    
    fileprivate func show(_ position: ToatPosition) {
        let window = UIApplication.shared.keyWindow!
        
        switch position {
        case .center:
            containerView.center = window.center
        case .top:
            containerView.center = CGPoint(x: window.center.x, y: offset+containerView.height/2)
        case .bottom:
            containerView.center = CGPoint(x: window.center.x, y: window.frame.size.height-(offset+containerView.height/2))
        }
        window.addSubview(containerView)
        showAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(duration) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.hideAnimation()
        }
    }
}


extension ToastView{
    class func showWithMessage(_ message: String, duration: CGFloat = 2, position: ToatPosition = .center){
        
        DispatchQueue.main.async { 
            let toast = ToastView(text: message)
            if duration != 0{
                toast.duration = duration
            }
            toast.show(position)
        }
    }
    
}
