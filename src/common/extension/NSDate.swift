//
//  NSDate.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation

extension Date{
    
    /**
     返回当前时区时间
     */
    public func hg_Localdate() -> Date{
        let timeZone = TimeZone.autoupdatingCurrent
        let seconds : TimeInterval = Double(timeZone.secondsFromGMT(for: self))
        let localDate = Date(timeInterval: seconds, since: self)
        return localDate
    }
    
    public func hg_getDateTimeToMilliSeconds() -> CUnsignedLongLong{
        let timeInterval = self.timeIntervalSince1970
        return CUnsignedLongLong(timeInterval * 1000)
    }
    
    
    public static func hg_getDateFromMillSeconds(_ millSeconds:CUnsignedLongLong) -> Date{
        let tempSeconds = TimeInterval(millSeconds)
        let seconds = tempSeconds/1000
        return Date(timeIntervalSince1970: seconds)
    }
    
    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
}
