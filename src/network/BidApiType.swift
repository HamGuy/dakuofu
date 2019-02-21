//
//  BidApiType.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol BidApiType: APIType {
    func listResponseData(_ json: JSON) -> Result<(JSON, JSON, Bool)>
}

 extension BidApiType {
    
     var baseURL: String {
        return "http://114.55.178.232/"
    }
    
    /**
     序列化处理数据
     
     - parameter json: 原始的 JSON
     
     - returns: Result 封装的结果 (data 字段内容, items 字段内容, 是否为最后一页)
     */
     func listResponseData(_ json: JSON) -> Result<(JSON, JSON, Bool)> {
        let errorJSON = json["error"]
        if errorJSON.isExists() {
            if let code = json["code"].int {
                let error = NetworkingError(rawValue: code) ?? NetworkingError.unknowError
                return Result.fail(error)
            }
        }
        
        let data = json["_embedded"]
        if !data.isExists() {
            return Result.fail(NetworkingError.invalidRespondData)
        }
        
        let items = data["bids"]
        if !items.isExists() {
            return Result.fail(NetworkingError.invalidRespondData)
        }
        
        return Result.success(json, items, Page.isReachEnd(json["page"]))
    }
}


struct OAuthApi {}

struct UserApi {}

struct BidApi {}
