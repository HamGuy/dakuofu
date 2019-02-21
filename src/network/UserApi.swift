//
//  UserApi.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension UserApi{
    /**
     *  获取用户信息
     */
    struct GetInfo: BidApiType {
        enum SearchType: Int{
            case username
            case id
        }
        
        let value:String
        let searchType: SearchType
        
        init(value: String, searchType:SearchType = .username){
            self.value = value
            self.searchType = searchType
        }
        
        var method: Alamofire.Method{
            return .GET
        }
        
        var path: String{
            return  searchType == .username ? "/api/users/search/findByUsername" : "api/users/\(value)"
        }
        
        var parameters: [String : AnyObject]?{
            return searchType == .username ? ["username":value] : nil
        }
        
        func handleJSON(_ json: JSON) -> Result<UserInfo> {
            let info = UserInfo(json: json)
            return Result.success(info)
        }
    }
    
    struct ModifyInfo: BidApiType {
        let fileds: [String: AnyObject]
        let id: String
        
        init(id: String, fileds: [String:AnyObject]){
            self.fileds = fileds
            self.id = id
        }
        
        var method: Alamofire.Method{
            return .PATCH
        }
        
        var path: String{
            return "api/users/\(id)"
        }
        
        var parameters: [String : AnyObject]?{
            return fileds
        }
        
        var encoding: ParameterEncoding{
            return .JSON
        }
        
        
        func handleJSON(_ json: JSON) -> Result<UserInfo> {
            let info = UserInfo(json: json)
            return Result.success(info)
        }
    }
    
    /**
     *
     * 修改头像
     */
    
    struct ModifyAvatr: BidApiType{
        let fileData: Data
        
        init(data: Data){
            self.fileData = data
        }
        
        var method: Alamofire.Method{
            return .POST
        }
        
        var path: String{
            return "api/files?fileName=avatar.jpg"
        }
        
        func handleJSON(_ json: JSON) -> Result<UserInfo> {
            let info = UserInfo(json: json)
            return Result.success(info)
        }
        
        var encoding: ParameterEncoding{
            return .JSON
        }
        
        var headers: [String : String]{
            return ["Content-Type":"image/jpeg","Authorization":"Bearer \(UserContext.sharedContext.token!.access_token)"]
        }
        
        func sendRequest(_ completion:@escaping (_ success:Bool, _ picture:String?)->Void){
            
            
            
            let mutableURLRequest =  NSMutableURLRequest(url: URL(string: self.url)!)
            //return ["Authorization":"Bearer \(token.access_token)"]
            mutableURLRequest.setValue("Bearer \(UserContext.sharedContext.token!.access_token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.httpBody = fileData
            mutableURLRequest.httpMethod = "POST"
            Alamofire.request(mutableURLRequest).responseString { response in
                if let error = response.result.error{
                    completion(success: false, picture: error.localizedDescription)
                }else{
                    completion(success: true, picture: response.result.value!)
                }
            }
        }
    }

    struct SearchUser: BidApiType {
        let keyword: String
        let searchType: Type
        
        enum Type: String{
            case phone = "findByPhone"
            case username = "findByUsername"
        }
        
        init(keyword: String, type: Type = .phone){
            self.keyword = keyword
            self.searchType = type
        }
        
        var method: Alamofire.Method{
            return .GET
        }
        
        var path: String{
            return "api/users/search/\(self.searchType.rawValue)"
        }
        
        var parameters: [String : AnyObject]?{
            return searchType == .phone ? ["phone":keyword] : ["username":keyword as AnyObject] as [String : AnyObject]?
        }
        
        func handleJSON(_ json: JSON) -> Result<UserInfo> {
            let info = UserInfo(json: json)
            return Result.success(info)
        }

        
    }
    
}
