//
//  Persistable.swift
//  Aspirin
//
//  Created by HamGuy on 8/27/16.
//
//

import Foundation

/**
 *  持久化协议，用于各种缓存
 */
public protocol Persistable: class{
    
    var persistantFileName: String { get }
    var persistentObject: AnyObject { get set }
    
    func load()
    func save() -> Bool
    
    func clear()
    func insertObject(_ obj: AnyObject, key: String?)
    func deleteObject(_ obj: AnyObject)
    func containsObject(_ obj: AnyObject) -> Bool
}

extension Persistable{
    
    var filePath: String {
        get {
            return PathHelper.filePathInDocument(persistantFileName)
        }
    }
    
    public  func load(){
        if FileManager.default.fileExists(atPath: filePath){
            if let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath){
                persistentObject = data as AnyObject
            }
        }else{
            persistentObject = [NSCoding]() as AnyObject
        }
    }
    
    public func save() -> Bool{
        let data = NSKeyedArchiver.archivedData(withRootObject: persistentObject)
        let result = (try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])) != nil
        if !result{
            debugPrint("Persistent operation failed with file: \(filePath)")
        }
        return result
    }
    
    public func clear(){
        if var arrayObjects = persistentObject as? [AnyObject]{
            arrayObjects.removeAll()
        }
        
        if var dictonayObject = persistentObject as? [String:AnyObject]{
            dictonayObject.removeAll()
        }

        save()
    }
    
    public func insertObject(_ obj: AnyObject, key: String? = nil){
        if var arrayObjects = persistentObject as? [AnyObject] , !containsObject(obj){
            arrayObjects.append(obj)
            save()
        }
        
        if var dictionaryObject = persistentObject as? [String: AnyObject]{
            if let keyValue = key , !dictionaryObject.keys.contains(keyValue){
                dictionaryObject[keyValue] = obj
                save()
            }
        }
    }
}
