//
//  FindPasswordController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire

class FindPasswordController: UIViewController {
    
    @IBOutlet weak var phoneField:UIMaterialTextField!
    @IBOutlet weak var codeField:UIMaterialTextField!
    @IBOutlet weak var passwordField:UIMaterialTextField!
    @IBOutlet weak var repeatPasswordField:UIMaterialTextField!
    
    @IBOutlet weak var verifyCodeButton:RoundedButton!
    
    fileprivate var oauthRequest:Request?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "找回密码"
        phoneField.delegate = self
        verifyCodeButton.isEnabled = false
    }
    
    @IBAction func getVerifyCode(_ sender:UIButton){
        let api = OAuthApi.GetVerifyCode(phone: phoneField.text!)
        oauthRequest = hg_request(api, completion: {[weak self] response in
            self?.oauthRequest = nil
            sender.hg_countDown(60, countDownTitle: "秒后重新获取", completion: nil)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    @IBAction func done(_ sender:UIButton){
        if !passwordField.hg_isValidatePwd(){
            ToastView.showWithMessage("密码格式错误")
            return
        }
        
        if passwordField.text != repeatPasswordField.text{
            ToastView.showWithMessage("两次输入密码不一致！")
            passwordField.text = nil
            repeatPasswordField.text = nil
            return
        }
        
        let api = OAuthApi.FindPassword(phone: phoneField.text!,password: repeatPasswordField.text!,captcha: codeField.text!)
        oauthRequest = hg_request(api, completion: {[weak self] response in
            self?.oauthRequest = nil
            switch response{
            case .fail(let error):
                ToastView.showWithMessage("修改密码失败: \(error)")
            case .success( _):
                ToastView.showWithMessage("修改密码成功")
                self?.navigationController?.popViewControllerAnimated(true)
                break;
            }
        })
    }
}

extension FindPasswordController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !phoneField.hg_isTelephone(){
            ToastView.showWithMessage("无效的手机号码！")
            verifyCodeButton.isEnabled = false
        }else{
            verifyCodeButton.isEnabled = true
        }
    }
}
