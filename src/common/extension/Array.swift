//
//  Array.swift
//  dakuofu
//
//  Created by HamGuy on 9/8/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation

extension Array{
    public subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    public mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if(index != nil) {
            self.remove(at: index!)
        }
    }

}
