//
//  UserContext.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class UserContext: NSObject {
    
    static let sharedContext = UserContext()
    
    fileprivate override init() {
        super.init()
    }
    
    enum UserContextKeys: String {
        case username = "username"
        case token = "token"
        case avatar = "avatarurl"
        case phone = "phone"
        case followType = "followType"
        case remark = "remark"
        case realname = "realname"
        case address = "address"
        case id = "id"
        case allowPush = "allowPush"
    }
    
    var username :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.username.rawValue) as? String
        }set{
            if username != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.username.rawValue)
            }
        }
    }
    
    var token :Token?{
        get{
            if let dict = UserDefaultHelper.objectForKey(UserContextKeys.token.rawValue) as? [String : AnyObject]{
                return Token(object: dict)
            }
            return nil
        }set{
            if token != newValue{
                UserDefaultHelper.setObject(newValue?.dictionaryRepresentation(), key: UserContextKeys.token.rawValue)
            }
        }
    }
    
    var avatar :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.avatar.rawValue) as? String
        }set{
            if avatar != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.avatar.rawValue)
            }
        }
    }
    
    var phone :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.phone.rawValue) as? String
        }set{
            if phone != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.phone.rawValue)
            }
        }
    }
    
    var followType :Int{
        get{
            if let number = UserDefaultHelper.objectForKey(UserContextKeys.followType.rawValue) as? NSNumber{
                return number.intValue
            }
            return -1
        }set{
            if followType != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.followType.rawValue)
            }
        }
    }
    
    var remark :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.remark.rawValue) as? String
        }set{
            if remark != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.remark.rawValue)
            }
        }
    }
    
    var realname :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.realname.rawValue) as? String
        }set{
            if realname != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.realname.rawValue)
            }
        }
    }
    
    var address :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.address.rawValue) as? String
        }set{
            if address != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.address.rawValue)
            }
        }
    }
    
    var userId :String?{
        get{
            return UserDefaultHelper.objectForKey(UserContextKeys.id.rawValue) as? String
        }set{
            if userId != newValue{
                UserDefaultHelper.setObject(newValue, key: UserContextKeys.id.rawValue)
            }
        }
    }
    
    var allowPush: Bool{
        get {
            if let number = UserDefaultHelper.objectForKey(UserContextKeys.allowPush.rawValue) as? NSNumber{
                return number.boolValue
            }
            return false
        }
        set{
            if allowPush != newValue{
                UserDefaultHelper.setObject(NSNumber(value: newValue as Bool), key: UserContextKeys.allowPush.rawValue)
            }
        }
    }

    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    var hadLogin:Bool {
        get{
            return token?.access_token.length > 0
        }
    }
    
    var followTypeText: String{
        return followType != -1 ?  allFollowTypeText[followType] : ""
    }
    
    var followTypeEnum: FollowType{
        return FollowType(rawValue: allFollowTypes[followType])!
    }
    
    func update(_ userInfo:UserInfo){
        username = userInfo.username
        followType = allFollowTypes.index(of: userInfo.followType)!
        phone = userInfo.phone
        realname = userInfo.realname
        userId = userInfo.userId
        avatar = userInfo.image
        remark = userInfo.remark
        address = userInfo.address
        allowPush = userInfo.allowPush
    }
    
    func logOut(){
        token = nil
        username = nil
        followType = -1
        realname = nil
        address = nil
        phone = nil
        avatar = nil
        remark = nil
    }
}
