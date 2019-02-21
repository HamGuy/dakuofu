//
//  String.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import UIKit

extension String{
    public var length: Int {
        get {
            return self.characters.count
        }
    }
    
    public func contains(_ s: String) -> Bool
    {
        return (self.range(of: s) != nil) ? true : false
    }
    
    public func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    public subscript (i: Int) -> Character
        {
        get {
            let index = characters.index(startIndex, offsetBy: i)
            return self[index]
        }
    }
    
    public subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex =  self.characters.index(self.startIndex, offsetBy: r.lowerBound) //advance(self.startIndex, r.startIndex)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound-1) //advance(self.startIndex, r.endIndex - 1)
            
            return self[Range(startIndex ..< endIndex)]
        }
    }
    
    public func subString(_ startIndex: Int, length: Int) -> String
    {
        if length < 0 {
            return ""
        }
        
        let start = self.characters.index(self.startIndex, offsetBy: startIndex) //advance(self.startIndex, startIndex)
        let end = self.characters.index(self.startIndex, offsetBy: (startIndex + length)) //advance(self.startIndex, startIndex + length)
        return self.substring(with: Range<String.Index>(start ..< end))
    }
    
    public func subStringFromIndex(startInex index:Int) -> String{
        return self.subString(index, length: self.length-index)
    }
    
    public func subStringToIndex(endIndex index:Int)->String{
        return self.subString(0, length: index)
    }
    
    public func indexOf(_ target: String) -> Int
    {
        let range = self.range(of: target)
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound) //distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    public func indexOf(_ target: String, startIndex: Int) -> Int
    {
        let startRange = self.characters.index(self.startIndex, offsetBy: startIndex) //advance(self.startIndex, startIndex)
        
        let range = self.range(of: target, options: NSString.CompareOptions.literal, range: Range<String.Index>(startRange ..< self.endIndex))
        
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound) //distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    public func lastIndexOf(_ target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    public func isMatch(_ regex: String, options: NSRegularExpression.Options) -> Bool
    {
        do {
            let exp = try NSRegularExpression(pattern: regex, options: options) as NSRegularExpression
            
            let matchCount = exp.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.length))
            return matchCount > 0}
        catch let error as NSError{
            print(error.localizedDescription)
            return false
        }
    }
    
    public func getMatches(_ regex: String, options: NSRegularExpression.Options) -> [NSTextCheckingResult]{
        do{
            
            let exp = try NSRegularExpression(pattern: regex, options: options) as NSRegularExpression
            
            let matches = exp.matches(in: self, options: [], range: NSMakeRange(0, self.length))
            return matches
        }
            
        catch let error as NSError{
            print(error.localizedDescription)
            return []
        }
    }
    
    public func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }
}


extension String{
    public func hg_AttributedString(_ attribute:(lineSpace:CGFloat,font:UIFont)) -> NSAttributedString{
        let style = NSMutableParagraphStyle()
        style.lineSpacing = attribute.lineSpace
        style.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        let attr = [NSParagraphStyleAttributeName:style,NSFontAttributeName:attribute.font]
        let multableString = NSMutableAttributedString(string: self, attributes: attr)
        return multableString
    }
    
    public func hg_AttributedStringSize(_ attribute:(lineSpace:CGFloat,font:UIFont),limitedSize:CGSize)->CGSize{
        let style = NSMutableParagraphStyle()
        style.lineSpacing = attribute.lineSpace
        style.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let attr = [NSParagraphStyleAttributeName:style,NSFontAttributeName:attribute.font]
        
        let size = (self as NSString).boundingRect(with: limitedSize, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: attr, context: nil).size
        
        return size
        
    }
}


let dateFormatter:DateFormatter =  DateFormatter()
extension String{
    public func hg_dateFromString(_ dateFormat:String)->Date?{
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: self)
        return date?.hg_Localdate()
    }
}

