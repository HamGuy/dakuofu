//
//  UserDefaultHelper.swift
//  dakuofu
//
//  Created by HamGuy on 9/1/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

class UserDefaultHelper: NSObject {
    static let userDefault:UserDefaults = UserDefaults.standard
    
    class func setObject(_ obj: AnyObject?, key: String){
        userDefault.set(obj, forKey: key)
        userDefault.synchronize()
    }
    
    class  func objectForKey(_ key: String) -> AnyObject?{
        return userDefault.object(forKey: key) as AnyObject?
    }
    
    class func firstTimeRunning(_ key: String, completion:(_ firstTimeRunning: Bool)->Void){
        if let obj = objectForKey(key) as? NSNumber , obj.boolValue {
            completion(false)
        }else{
            completion(true)
            setObject(true as AnyObject?, key: key)
        }
    }
}
