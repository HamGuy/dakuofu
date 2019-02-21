//
//  PopContiner.swift
//  Aspirin
//
//  Created by HamGuy on 7/16/15.
//
//

import UIKit

class PopContiner: UIView {
    
    static let sharedContainer = PopContiner()
    
    fileprivate var animationDuration:CGFloat = 0
    fileprivate var cancelOperationBlock:(()->Void)?
    
    
    var targetAlpha:CGFloat = 0.3
    
    internal var viewToShow:UIView?
    
    internal lazy var maskview:UIView = {
        let aView = UIView(frame: self.bounds)
        aView.backgroundColor = UIColor.black
        aView.isUserInteractionEnabled = true
        aView.alpha = 0
        return aView
    }()
    
    internal lazy var bottomMaskview:UIView = {
        let aView = UIView(frame: self.bounds)
        aView.backgroundColor = UIColor.black
        aView.isUserInteractionEnabled = true
        aView.alpha = 0
        return aView
    }()
    
    internal lazy var tapGesture:UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PopContiner.tapMask(_:)))
        return gesture
    }()
    
    
    // MARK: - Class Func
    
    class func showWithView(_ viewToShow:UIView, animationDuration:CGFloat = 0.5, tapToDissmiss:Bool = true, completion:(()->Void)? = nil, cancelBlock:(()->Void)? = nil){
        self.sharedContainer.show(viewToShow, animationDuration: animationDuration, tapToDissmiss: tapToDissmiss, completion: completion,cancelBlock: cancelBlock)
    }
    
    class func changeTargetAlpha(_ newAlpha:CGFloat) {
        self.sharedContainer.targetAlpha = newAlpha
    }
    
    class func dissmiss(_ completion:(()->Void)? = nil){
        self.sharedContainer.dissMiss(completion)
    }
    
    // MARK: - Private
    
    
    fileprivate func show(_ viewToShow:UIView,animationDuration:CGFloat, tapToDissmiss:Bool, completion:(()->Void)?, cancelBlock:(()->Void)? = nil){
        guard let window = UIApplication.shared.keyWindow else{
            return
        }
        self.animationDuration = animationDuration
        self.removeGestureRecognizer(self.tapGesture)
        
        self.removeAllSubviews()
        
        self.frame = window.bounds
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.alpha = 1
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth ,UIViewAutoresizing.flexibleHeight]
        
        self.maskview.height = self.height - viewToShow.height
        self.addSubview(self.maskview)
        self.bottomMaskview.height = viewToShow.height
        self.bottomMaskview.top = self.maskview.height
        self.addSubview(self.bottomMaskview)
        self.viewToShow = viewToShow
        self.addSubview(self.viewToShow!)

        
        if tapToDissmiss{
            self.cancelOperationBlock = cancelBlock
            self.maskview.addGestureRecognizer(self.tapGesture)
        }
        
        window.addSubview(self)
        
        self.viewToShow!.top = kScreenHeight
        UIView.animate(withDuration: TimeInterval(animationDuration), animations: {() -> Void in
            self.viewToShow!.top = kScreenHeight - self.viewToShow!.height
            self.maskview.alpha = self.targetAlpha
            self.bottomMaskview.alpha = self.targetAlpha
            }, completion: { (finished) -> Void in
            if finished && (completion != nil){
                completion!()
            }
        }) 
    }
    
    fileprivate func dissMiss(_ completion:(()->Void)? = nil){
        UIView.animate(withDuration: TimeInterval(self.animationDuration), animations: {() -> Void in
            self.viewToShow!.top = kScreenHeight
            self.maskview.alpha = 0
            self.bottomMaskview.alpha = 0
            }, completion: { (finished) -> Void in
                if finished && (completion != nil){
                    completion!()
                }
                if finished{
                self.removeFromSuperview()
                }
        }) 
    }
    
    // MARK: - actions
    func tapMask(_ gesture:UITapGestureRecognizer){
        if  gesture.view == self.maskview{
            if let theBlock = self.cancelOperationBlock{
                theBlock()
            }
            self.dissMiss()
        }
    }
    
    
    
}
