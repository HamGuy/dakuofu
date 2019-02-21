//
//  File.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import PKHUD
import IQKeyboardManagerSwift

extension UIViewController{
    // MARK: - Custom Bar Item
    // MARK: - Custom Bar Item - Public - Text
    func hg_AddLeftBarButtonItemText(_ title:String , action:Selector){
        self.navigationItem.leftBarButtonItem = barItemWithText(title,action: action)
    }
    
    func hg_AddRightBarButtonItemText(_ title:String , action:Selector){
        self.navigationItem.rightBarButtonItem = barItemWithText(title, action: action)
    }
    
    // MARK: - Custom Bar Item - Private
    fileprivate func barItemWithText(_ title:String , action:Selector)->UIBarButtonItem!{
        let font = UIFont.systemFont(ofSize: 17.0)
        let titleTintColor = UIColor.white
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        item.setTitleTextAttributes([NSForegroundColorAttributeName:titleTintColor,NSFontAttributeName:font], for: UIControlState())
        return item
    }
    
    fileprivate typealias alertAction = ((_ btnIndex:Int)->())?
    
    func hg_showAlert(_ message:String, title:String? = "提示", cancelTitle:String? = "确定", cancelBlock:(()->Void)? = nil ,otherTitle:String? = nil ,otherBlock:(()->Void)? = nil){
        
        let completionBlock:(Int)->Void = {(btnIndex)->Void in
            if btnIndex == 0{
                if cancelBlock != nil{
                    cancelBlock!()
                }
            }
            if btnIndex == 1{
                if otherBlock != nil{
                    otherBlock!()
                }
            }
        }
        
        self.hg_showAlertContrller(message, title: title, cancelTitle: cancelTitle, otherTitle: otherTitle, completion: { (btnIndex) -> () in
            completionBlock(btnIndex)
        })
        
        
    }
    
    fileprivate func hg_showAlertContrller(_ message:String, title:String?, cancelTitle:String?,otherTitle:String? ,completion:alertAction)->UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            if(completion != nil){
                completion!(0)
            }
        }))
        if(otherTitle != nil){
            alertController.addAction(UIAlertAction(title: otherTitle!, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                if(completion != nil){
                    completion!(1)
                }
            }))
        }
        self.present(alertController, animated: true, completion: nil)
        return alertController
    }

    func startLoading(){
        HUD.flash(.Progress)
    }
    
    func stopLoading(){
        HUD.hide()
    }
    
    func hideKeyBoard(){
        dismissKeyboard()
       // IQKeyboardManager.sharedManager().resignFirstResponder()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showMainTabController(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let sb = storyboard{
            let tabController = sb.instantiateViewController(withIdentifier: "mainTabController")
            app.window?.rootViewController = tabController
        }
    }
    
}


extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
