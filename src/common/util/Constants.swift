//
//  Constants.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height


let appId = "clientapp"
let appSecret = "123456"
let callBackUrl = ""
let kDefaultFollowTypeKey = "defaultFollowType"

func isLaterThanOsVersion(_ majorVersion:String)->Bool{
    return UIDevice.current.systemVersion.compare(majorVersion, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

enum FollowType: String{
    case car = "car"
    case hourse = "house"
    case asserts = "assert"
    case project = "project"
    case land = "land"
}

enum SortType: String{
    case titleAsc = "title,asc"
    case titleDesc = "title,desc"
    case followedUserCountDesc = "followedUserCount,desc"
    case followedUserCountAsc = "followedUserCount,asc"
    case priceDesc = "price,desc"
    case priceAsd = "price,asc"
    case createTimeDesc = "createTime,desc"
    case createTimeAsc = "createTime,asc"
}


let allFollowTypes = ["car","house","assert","project","land"]
let allFollowTypeText = ["机动车","房产","资产","工程","土地"]

let allSortTypes = ["title,asc", "title,desc", "followedUserCount,desc","createTime,desc","price,desc","price,asc"]
let allSortTypeText = ["字母升序","字母降序","人气最高","最新上架","价格最高","价格最低"]

#if DEBUG
    let gtAppId = "eLfVzTxQfxATjmHpnG0u89"
    let gtAppSecret = "wimLcWXPyp6pKKRMcKlc0A"
    let gtAppKey = "JcGcTxY5nj7citiTF7Kis3"
#else
    let gtAppId = "DuWxtVuMqP6BcawVjneZP8"
    let gtAppSecret = "7a6mKfVk4BAbrEoKYoCx37"
    let gtAppKey = "mnmzOLBBzk7uKkCuJB35t2"
#endif


let kLoginSuccessNotification = "khgLoginSuccess"
