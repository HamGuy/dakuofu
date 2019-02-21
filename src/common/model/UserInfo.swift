//
//  UserInfo.swift
//  dakuofu
//
//  Created by HamGuy on 9/9/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import SwiftyJSON


struct UserInfo {
    /*
     "phone" : "62325415279",
    "username" : "jaron",
    "realname" : "银教授",
    "followType" : "car",
    "address" : "紫金港路",
    "image" : null,
    "remark" : "没钱买"
     */
    
    let phone: String
    let username: String
    let realname: String
    let followType: String
    let address: String?
    let image: String?
    let remark: String?
    let userId: String
    let allowPush: Bool
    
    
    enum KeyValues: String{
        case phone = "phone"
        case username = "username"
        case realname = "realname"
        case followType = "followType"
        case address = "address"
        case image = "image"
        case remark = "remark"
        case allowPush = "allowPush"
    }
    
    init(json:JSON){
        phone = json[KeyValues.phone.rawValue].stringValue
        username = json[KeyValues.username.rawValue].stringValue
        realname = json[KeyValues.realname.rawValue].stringValue
        address = json[KeyValues.address.rawValue].string
        followType = json[KeyValues.followType.rawValue].stringValue
        image = json[KeyValues.image.rawValue].string
        remark = json[KeyValues.remark.rawValue].string
        if let links = json["_links"].dictionary, let target = links["self"]?.dictionary, let href = target["href"]?.string{
            userId = href.subStringFromIndex(startInex: href.lastIndexOf("/")+1)
        }else if let theId = json["id"].int{
            userId = "\(theId)"
        }else{
            userId = "-1"
        }
        allowPush = json[KeyValues.allowPush.rawValue].boolValue
    }
}
