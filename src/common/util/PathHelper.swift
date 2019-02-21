//
//  PathHelper.swift
//  Aspirin
//
//  Created by HamGuy on 8/25/16.
//
//

import UIKit

@objc
open class PathHelper: NSObject {
    
    fileprivate static var documentPath: String?
    fileprivate static var cachePath: String?
    fileprivate static let KVaccineListFileName = "Vaccines"
    fileprivate static let KVaccinesAndMembersMappingFileName = "VaccineCalendarEventIdentifiers"
    fileprivate static let KVaccineCalendarEventsFilePathName = "VaccineCalendarEventIdentifiers"
    fileprivate static let KQueryFailedBarcodeListFilePathName = "QueryFailedBarcodes"
    
    
    open class func documentDirectory() -> String{
        if documentPath == nil{
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory
                , .userDomainMask, true)
            documentPath = paths[0]
        }
        return documentPath!
    }
    
    open class func cacheDirectory() -> String{
        if cachePath == nil{
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory
                , .userDomainMask, true)
            cachePath = paths[0]
        }
        return cachePath!
    }
    
    open class func filePathInDocument(_ filename: String) -> String {
        return (documentDirectory() as NSString).appendingPathComponent(filename)
    }
    
    open class func filePathInCacheDirectory(_ filename: String) -> String {
        return (cacheDirectory() as NSString).appendingPathComponent(filename)
    }
    
    open class func filePathInMainBundle(_ filename: String?) -> String?{
        guard let filename = filename else {
            return nil
        }
        
        let keywords = filename.components(separatedBy: ".")
        let suffix = keywords.last! as String
        let length = filename.length - suffix.length
        let name = filename.subStringToIndex(endIndex: length - 1)
        let path = Bundle.main.path(forResource: name, ofType: suffix)
        return path
    }
    
    open class func vaccineListFilePath() -> String?{
        return filePathInDocument(KVaccineListFileName)
    }
    
    open class func vaccinesAndMembersMappingFilePath() -> String?{
        return filePathInDocument(KVaccinesAndMembersMappingFileName)
    }
    
    open class func vaccineCalendarEventsFilePath() -> String?{
        return filePathInDocument(KVaccineCalendarEventsFilePathName)
    }
    
    open class func queryFailedBarcodeListFilePath() -> String?{
        return filePathInDocument(KQueryFailedBarcodeListFilePathName)
    }

    
}
