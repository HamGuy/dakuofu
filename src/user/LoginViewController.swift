//
//  LoginViewController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var nameFiled:UIMaterialTextField!
    @IBOutlet weak var passwordField:UIMaterialTextField!

    var request:Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.setNavigationBarHidden(false, animated: true)
        view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension LoginViewController{
    @IBAction func login(_ sender:UIButton){
        
        if nameFiled.text?.length == 0{
            ToastView.showWithMessage("用户名不能为空")
            return
        }
        
        if passwordField.text?.length == 0{
            ToastView.showWithMessage("密码不能为空")
            return
        }
        
        if !nameFiled.hg_isValidateAccount(){
            ToastView.showWithMessage("账号格式错误")
            return
        }
        
        if !passwordField.hg_isValidatePwd(){
            ToastView.showWithMessage("密码格式错误")
            return
        }
        
        startLoading()
        let api = OAuthApi.Login(account: nameFiled.text!, pwd: passwordField.text!)
        request = hg_request(api, completion: {[weak self] response in
            self?.request = nil

            switch response{
            case .fail( let error):
                self?.stopLoading()
                ToastView.showWithMessage("登录失败: \(error)")
            case .success(let token):
                ToastView.showWithMessage("登录成功")
                UserContext.sharedContext.token = token
                if UserContext.sharedContext.userId == nil{
                    self?.getUserInfo()
                }
                self?.showMainTabController()
                NSNotificationCenter.defaultCenter().postNotificationName(kLoginSuccessNotification, object: nil)
                break;
            }
        })
        
    }
    
    func getUserInfo(){
        let api = UserApi.GetInfo(value: nameFiled.text!)
        request = hg_request(api, completion: { [weak self] response in
            self?.request = nil
            self?.stopLoading()
            switch response{
            case .fail(_):
                ToastView.showWithMessage("获取用户信息失败")
            case .success(let userinfo):
                 UserContext.sharedContext.update(userinfo)
                 self?.showMainTabController()
                break;
            }
        })
    }
    
    @IBAction func register(_ sender:UIButton){
        if let sb = storyboard{
            let regController = sb.instantiateViewController(withIdentifier: "registerController")
            let navController = UINavigationController(rootViewController: regController)
            present(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func findPassword(_ sender:UIButton){
        if let sb = storyboard{
            let findPwdController = sb.instantiateViewController(withIdentifier: "findPassowrdController")
            self.navigationController?.pushViewController(findPwdController, animated: true)
        }
    }
    
}
