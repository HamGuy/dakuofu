//
//  NSUserDefault.swift
//  dakuofu
//
//  Created by HamGuy on 9/8/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    fileprivate var requestedNotificationsDefaultKey: String {
        return "permission.requestedNotifications"
    }
    
    public var requestedNotifications: Bool {
        get {
            return bool(forKey: requestedNotificationsDefaultKey)
        }
        set {
            set(newValue, forKey: requestedNotificationsDefaultKey)
            synchronize()
        }
    }
}
