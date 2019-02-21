//
//  Page.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Page {
    
    /*
     "page" : {
     "size" : 3,
     "totalElements" : 66,
     "totalPages" : 22,
     "number" : 0
     }*/
    
    public let size: Int
    public let totalElements: Int
    public let totalPages: Int
    public let number: Int
    
    fileprivate enum ValueKey: String {
        case number = "number"
        case size = "size"
        case totalPages = "totalPages"
        case totalElements = "totalElements"
    }
    
    
    init(json: JSON) {
        self.size = json[ValueKey.size.rawValue].intValue
        self.totalElements = json[ValueKey.totalElements.rawValue].intValue
        self.totalPages = json[ValueKey.totalPages.rawValue].intValue
        self.number = json[ValueKey.number.rawValue].intValue
    }
}


public extension Page {
    
    public static func isReachEnd(_ json: JSON) -> Bool {
         let pageInfo = Page(json: json)
        return pageInfo.number >= pageInfo.totalPages
    }
}


