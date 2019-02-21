//
//  FavoriteContext.swift
//  dakuofu
//
//  Created by HamGuy on 9/8/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation

class  FavoriteContext: NSObject {
    static let sharedContext = FavoriteContext()
    var favotiteBids: [CorporeItem] = []
    
    fileprivate override init(){
        super.init()
        self.load()
    }
}

extension FavoriteContext: Persistable{
    var persistentObject: AnyObject{
        get{
            return favotiteBids as AnyObject
        }
        set{
            if let data = newValue as? [CorporeItem]{
                favotiteBids = data
            }
        }
    }
    
    var persistantFileName: String{
        return "dkfFavoriteBids"
    }
    
    func containsObject(_ obj: AnyObject) -> Bool {
        if let item = obj as? CorporeItem{
            let results = favotiteBids.filter { $0.id == item.id }
            return results.count > 0
        }
        return false
    }
    
    func deleteObject(_ obj: AnyObject) {
        if let itemToRemove = obj as? CorporeItem{
            let results = favotiteBids.filter { $0.id == itemToRemove.id }
            if results.count > 0{
                favotiteBids.removeObject(itemToRemove)
            }
            save()
        }
    }

}
