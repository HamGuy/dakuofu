//
//  RegisterViewController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import IQKeyboardManagerSwift

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameField:UIMaterialTextField!
    @IBOutlet weak var passwordField:UIMaterialTextField!
    @IBOutlet weak var repeatPasswordField:UIMaterialTextField!
    @IBOutlet weak var nameField:UIMaterialTextField!
    @IBOutlet weak var phoneField:UIMaterialTextField!
    @IBOutlet weak var codeField:UIMaterialTextField!
    @IBOutlet weak var verifyCodeButton:RoundedButton!
    @IBOutlet weak var registerButton:RoundedButton!
    @IBOutlet weak var followTypeButton:UIButton!
    
    fileprivate var followTypeIndex = -1
    var oauthRequest: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        hg_AddLeftBarButtonItemText("取消",action: #selector(RegisterViewController.cancel))
        registerButton.isEnabled = false
        verifyCodeButton.isEnabled = false
        phoneField.delegate = self
        codeField.delegate = self
        usernameField.delegate = self
        
//        #if DEBUG
//            usernameField.text = "ham"
//            passwordField.text = "qswa1234"
//            repeatPasswordField.text = "qswa1234"
//            phoneField.text = "18314895939"
//            nameField.text = "哈姆"
//        #endif
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func cancel(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController{
    @IBAction func register(_ sender:UIButton){
        if !usernameField.hg_isValidateAccount(){
            ToastView.showWithMessage("账号格式错误！")
            return
        }
        
        if !passwordField.hg_isValidatePwd(){
            ToastView.showWithMessage("密码格式错误！")
            return
        }
        
        if passwordField.text != repeatPasswordField.text{
            ToastView.showWithMessage("两次输入密码不一致！")
            passwordField.text = nil
            repeatPasswordField.text = nil
            return
        }
        
        if followTypeIndex == -1{
            ToastView.showWithMessage("请选择关注类型")
            return
        }
        
        if nameField.text?.length == 0{
            ToastView.showWithMessage("姓名不能为空！")
            return
        }
        
        oauthRequest?.cancel()
        let api = OAuthApi.Register(account: usernameField.text!, password: repeatPasswordField.text!, followType:allFollowTypes[followTypeIndex] , phone: phoneField.text!, realname: nameField.text!, code: codeField.text!)
        oauthRequest = hg_request(api, completion: {[weak self] response in
            self?.oauthRequest = nil
            switch response{
            case .fail(let error):
                ToastView.showWithMessage("注册失败: \(error)")
            case .success(let userInfo):
                ToastView.showWithMessage("注册成功")
                UserContext.sharedContext.update(userInfo)
                self?.dismissViewControllerAnimated(true, completion: {
                    
                })
                break;
            }

        })
        
    }
    
    @IBAction func getVerifyCode(_ sender:RoundedButton){
        let api = OAuthApi.GetVerifyCode(phone: phoneField.text!)
        self.oauthRequest = hg_request(api, completion: { response in
            sender.hg_countDown(60, countDownTitle: "秒后重新获取", completion: nil)
        })
    }
    
    @IBAction func selectFollowType(_ sender:UIButton){
        IQKeyboardManager.sharedManager().resignFirstResponder()
        sender.perform(#selector(UIResponder.resignFirstResponder), with: nil, afterDelay: 0.1)
        let picker = FollowTypePicker { index in
            self.followTypeButton.setTitle(allFollowTypeText[index], for: UIControlState())
            self.followTypeButton.setTitleColor(UIColor.appMinorColor, for: UIControlState())
            self.followTypeButton.tag = 1
            self.followTypeIndex = index
        }
        picker.show()
    }
}

extension RegisterViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameField && textField.hg_isValidateAccount(){
            let api = UserApi.SearchUser(keyword: textField.text!,type: .username)
            oauthRequest?.cancel()
            oauthRequest = hg_request(api, completion: { [weak self] response in
              self?.oauthRequest = nil
                switch response{
                case .fail(_):
                    break;
                case .success(_):
                    ToastView.showWithMessage("用户名已被占用")
                }
            })
            return
        }
        
        
        if textField == phoneField && textField.hg_isTelephone(){
            if textField.hg_isTelephone(){
                let api = UserApi.SearchUser(keyword: textField.text!)
                oauthRequest?.cancel()
                oauthRequest = hg_request(api, completion: { [weak self] response in
                    guard let strongSelf = self else { return }
                    strongSelf.oauthRequest = nil
                    switch response{
                    case .fail(_):
                         strongSelf.verifyCodeButton.enabled = true
                    case .success(_):
                         strongSelf.verifyCodeButton.enabled = false
                        ToastView.showWithMessage("手机号已被注册")
                    }
                    })

            }else{
                ToastView.showWithMessage("无效的手机号码！",duration: 2.0, position: .top)
                verifyCodeButton.isEnabled = false
            }
            return
        }
        
        if textField == codeField{
            registerButton.isEnabled = textField.text?.length == 4
            return
        }
    }
}
