//
//  OAuthApi+Login.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension OAuthApi{
    /**
     *  登录
     */
    struct Login : BidApiType{
        
        let userName: String
        let password: String
        
        init(account: String, pwd: String){
            self.userName = account
            self.password = pwd
        }
        var  method: Alamofire.Method {
            return .POST
        }
        
        var path: String{
            return "oauth/token"
        }
        
        var parameters: [String:AnyObject]?{
            return ["username":userName as AnyObject,"password":password as AnyObject,"grant_type":"password" as AnyObject]
        }
        
        var headers:[String:String]{
            if let plainData = "\(appId):\(appSecret)".data(using: String.Encoding.utf8){
                let base64Encoding = plainData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
                return ["Authorization":"Basic \(base64Encoding)"]
            }else{
                return [:]
            }
            
            
        }

        func handleJSON(_ json: JSON) -> Result<Token> {
            let token = Token(json: json)
            return Result.success(token)
        }
    }
    
    struct RefreshToken : BidApiType{
        
        var  method: Alamofire.Method {
            return .POST
        }
        
        var path: String{
            return "oauth/token"
        }
        
        var parameters: [String:AnyObject]?{
            return ["refresh_token":UserContext.sharedContext.token!.refresh_token as AnyObject,"grant_type":"refresh_token" as AnyObject]
        }
        
        var headers:[String:String]{
            if let plainData = "\(appId):\(appSecret)".data(using: String.Encoding.utf8){
                let base64Encoding = plainData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
                return ["Authorization":"Basic \(base64Encoding)"]
            }else{
                return [:]
            }
            
            
        }
        
        func handleJSON(_ json: JSON) -> Result<Token> {
            let token = Token(json: json)
            return Result.success(token)
        }
    }
    
    /**
     *  注册
     */
    struct Register:BidApiType {
        /*
         {"address":"杭州市西湖区浙大路","followType":"car","password":"123456","phone":"48507805915","realname":"银教授","remark":"没钱买","username":"isdhlt"}
         
         */
        
        let address: String?
        let followType: String
        let username: String
        let password: String
        let phone: String
        let realname: String
        let remark: String?
        let captcha: String
        
        enum KeyValus: String{
            case address = "address"
            case followType = "followType"
            case password = "password"
            case username = "username"
            case realname = "realname"
            case phone = "phone"
            case remark = "remark"
        }
        
        init(account: String, password: String, followType: String, phone: String, realname:String, code:String, address: String? = nil, remark: String? = nil){
            self.username = account
            self.password = password
            self.followType = followType
            self.phone = phone
            self.realname = realname
            self.captcha = code
            self.address = address
            self.remark = remark
        }
        
        var method: Alamofire.Method{
            return .POST
        }
        
        var path: String{
            return "api/register?captcha=\(self.captcha)"
        }
        
        var encoding: ParameterEncoding{
            return .JSON
        }
        
        var parameters: [String : AnyObject]?{
            return [KeyValus.username.rawValue:username as AnyObject,
                    KeyValus.password.rawValue:password as AnyObject,
                    KeyValus.phone.rawValue:phone as AnyObject,
                    KeyValus.followType.rawValue:followType as AnyObject,
                    KeyValus.realname.rawValue:realname as AnyObject,
            "allowPush":true as AnyObject]
        }
        
        func handleJSON(_ json: JSON) -> Result<UserInfo> {
            let info = UserInfo(json:json)
            return Result.success(info)
        }
    }
    
    /**
     *  找回密码
     */
    struct FindPassword: BidApiType {
        let phone: String
        let password: String
        let captcha: String
        
        init(phone: String, password: String, captcha: String){
            self.phone = phone
            self.password = password
            self.captcha = captcha
        }
        
        var method: Alamofire.Method{
            return .POST
        }
        
        var parameters: [String : AnyObject]?{
            return ["phone":phone as AnyObject,
                    "password":password as AnyObject,
                    "captcha":captcha as AnyObject]
        }
        
        var path: String{
            return "api/password"
        }
        
        func handleJSON(_ json: JSON) -> Result<Bool> {
            return Result.success(true)
            
        }
    }
    
    struct GetVerifyCode: BidApiType {
        let phone: String
        
        init(phone: String){
            self.phone = phone
        }
        
        var method: Alamofire.Method{
            return .POST
        }
        
        var parameters: [String : AnyObject]?{
            return ["phone":phone as AnyObject]
        }
        
        var path: String{
            return "api/captchas"
        }
        
        func handleJSON(_ json: JSON) -> Result<String> {
            return Result.success(json.rawString()!)
        }
    }
}
