//
//  Token.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import SwiftyJSON

class Token: NSObject, NSCoding{
    
    /*
     {"access_token":"6d7534c6-273a-4a2c-9351-98e740b2e91c","token_type":"bearer","refresh_token":"1a155876-e9a7-4898-8bfc-35f364c826d7","expires_in":2591999,"scope":"read write"}
     */
    
    var access_token: String
    var token_type: String
    var refresh_token: String
    var expires_in: Int
    var scope: String
    var createTime: Date
    
    enum KeyValues: String{
        case access_token = "access_token"
        case token_type = "token_type"
        case refresh_token = "refresh_token"
        case expires_in = "expires_in"
        case scope = "scope"
        case createTime = "date"
    }
    
    init(json: JSON){
        self.access_token = json[KeyValues.access_token.rawValue].string ?? ""
        self.token_type = json[KeyValues.token_type.rawValue].string ?? ""
        self.refresh_token = json[KeyValues.refresh_token.rawValue].string ?? ""
        self.expires_in = json[KeyValues.expires_in.rawValue].int ?? 0
        self.scope = json[KeyValues.scope.rawValue].string ?? ""
        createTime = NSDate()
    }
    
    convenience init(object: AnyObject) {
        self.init(json: JSON(object))
    }

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: KeyValues.access_token.rawValue)
        aCoder.encode(refresh_token, forKey: KeyValues.refresh_token.rawValue)
        aCoder.encode(expires_in, forKey: KeyValues.expires_in.rawValue)
        aCoder.encode(scope, forKey: KeyValues.scope.rawValue)
        aCoder.encode(token_type, forKey: KeyValues.token_type.rawValue)
        aCoder.encode(createTime, forKey: KeyValues.createTime.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.access_token = aDecoder.decodeObject(forKey: KeyValues.access_token.rawValue) as! String
        self.refresh_token = aDecoder.decodeObject(forKey: KeyValues.refresh_token.rawValue) as! String
        self.scope = aDecoder.decodeObject(forKey: KeyValues.scope.rawValue) as! String
        self.expires_in = (aDecoder.decodeObject(forKey: KeyValues.expires_in.rawValue) as! NSNumber).intValue
        self.token_type = aDecoder.decodeObject(forKey: KeyValues.token_type.rawValue) as! String
        self.createTime = aDecoder.decodeObject(forKey: KeyValues.createTime.rawValue) as! Date
    }
    
    func dictionaryRepresentation() -> [String : AnyObject ] {
        
        var dictionary: [String : AnyObject ] = [ : ]
        dictionary.updateValue(access_token as AnyObject, forKey: KeyValues.access_token.rawValue)
        dictionary.updateValue(refresh_token as AnyObject, forKey: KeyValues.refresh_token.rawValue)
        dictionary.updateValue(token_type as AnyObject, forKey: KeyValues.token_type.rawValue)
        dictionary.updateValue(expires_in as AnyObject, forKey: KeyValues.expires_in.rawValue)
        dictionary.updateValue(scope as AnyObject, forKey: KeyValues.scope.rawValue)
        
        return dictionary
    }
    
    
    var expired: Bool{
        get{
            let distance = Date().hg_Localdate().secondsFrom(createTime)
            if distance == -1{
                return false
            }
            return distance > expires_in
        }
    }
    
    
}
