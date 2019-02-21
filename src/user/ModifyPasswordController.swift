//
//  ModifyPasswordController.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
import Alamofire

class ModifyPasswordController: UIViewController {
    
    @IBOutlet weak var passwordField:UIMaterialTextField!
    @IBOutlet weak var repeatPasswordField:UIMaterialTextField!
    
    var oauthRequest: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改密码"
    }
    
    @IBAction func done(_ sender:UIButton){
        if !passwordField.hg_isValidatePwd(){
            ToastView.showWithMessage("密码格式错误")
            passwordField.becomeFirstResponder()
            return
        }
        
        if passwordField.text != repeatPasswordField.text{
            ToastView.showWithMessage("两次输入密码不一致！")
            passwordField.text = nil
            repeatPasswordField.text = nil
            return
        }
        
        let api = UserApi.ModifyInfo(id: UserContext.sharedContext.userId!, fileds: ["password":repeatPasswordField.text!])
        startLoading()
        oauthRequest = hg_request(api, completion: { [weak self] response in
            self?.oauthRequest = nil
            self?.stopLoading()
            switch response{
            case .fail(let error):
                ToastView.showWithMessage("修改密码失败: \(error)")
            case .success(let info):
                UserContext.sharedContext.update(info)
                ToastView.showWithMessage("修改密码成功")
                self?.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
}


