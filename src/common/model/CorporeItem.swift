//
//  CorporeItem.swift
//
//  Created by HamGuy on 9/5/16
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CorporeItem: NSObject, NSCoding {

    // MARK: Declaration for string constants to be used to decode and also serialize.
	internal let kCorporeItemPriceKey: String = "price"
	internal let kCorporeItemAddressKey: String = "address"
	internal let kCorporeItemTitleKey: String = "title"
	internal let kCorporeItemFollowedUserCountKey: String = "followedUserCount"
	internal let kCorporeItemDescriptionValueKey: String = "description"
	internal let kCorporeItemLinksKey: String = "_links"
	internal let kCorporeItemBidImagesKey: String = "bidImages"
	internal let kCorporeItemTypeKey: String = "type"
    internal let kCorporeItemCreateTimeKey:String = "createTime"
    internal let kCorporeItemTelephoneKey:String = "telephone"


    // MARK: Properties
	 var price: Int
	 var address: String?
	 var title: String?
	 var followedUserCount: Int?
	 var descriptionValue: String?
	 var bidImages: [String]?
	 var type: String?
     var id: Int = -1
    var createTime: Int
    var telephone:String


    // MARK: SwiftyJSON Initalizers
    /**
    Initates the class based on the object
    - parameter object: The object of either Dictionary or Array kind that was passed.
    - returns: An initalized instance of the class.
    */
    convenience init(object: AnyObject) {
        self.init(json: JSON(object))
    }

    /**
    Initates the class based on the JSON that was passed.
    - parameter json: JSON object from SwiftyJSON.
    - returns: An initalized instance of the class.
    */
    init(json: JSON) {
		price = json[kCorporeItemPriceKey].intValue
		address = json[kCorporeItemAddressKey].string
		title = json[kCorporeItemTitleKey].string
		followedUserCount = json[kCorporeItemFollowedUserCountKey].int
		descriptionValue = json[kCorporeItemDescriptionValueKey].string
		bidImages = []
		if let items = json[kCorporeItemBidImagesKey].array {
			for item in items {
				if let tempValue = item.string {
				bidImages?.append(tempValue)
				}
			}
		} else {
			bidImages = nil
		}
		type = json[kCorporeItemTypeKey].string
        if let links = json["_links"].dictionary, let target = links["self"]?.dictionary, let href = target["href"]?.string{
            let idString = href.subStringFromIndex(startInex: href.lastIndexOf("/")+1)
            id = Int(idString)!
        }
        createTime = json[kCorporeItemCreateTimeKey].intValue
        telephone = json[kCorporeItemTelephoneKey].stringValue
    }


    /**
    Generates description of the object in the form of a NSDictionary.
    - returns: A Key value pair containing all valid values in the object.
    */
    func dictionaryRepresentation() -> [String : AnyObject ] {

        var dictionary: [String : AnyObject ] = [ : ]
		
			dictionary.updateValue(price as AnyObject, forKey: kCorporeItemPriceKey)
		
		if address != nil {
			dictionary.updateValue(address! as AnyObject, forKey: kCorporeItemAddressKey)
		}
		if title != nil {
			dictionary.updateValue(title! as AnyObject, forKey: kCorporeItemTitleKey)
		}
		if followedUserCount != nil {
			dictionary.updateValue(followedUserCount! as AnyObject, forKey: kCorporeItemFollowedUserCountKey)
		}
		if descriptionValue != nil {
			dictionary.updateValue(descriptionValue! as AnyObject, forKey: kCorporeItemDescriptionValueKey)
		}
		if bidImages?.count > 0 {
			dictionary.updateValue(bidImages! as AnyObject, forKey: kCorporeItemBidImagesKey)
		}
		if type != nil {
			dictionary.updateValue(type! as AnyObject, forKey: kCorporeItemTypeKey)
		}
        
        dictionary.updateValue(telephone as AnyObject, forKey: kCorporeItemTelephoneKey)
        dictionary.updateValue(createTime as AnyObject, forKey: kCorporeItemCreateTimeKey)

        return dictionary
    }

    // MARK: NSCoding Protocol
    required init(coder aDecoder: NSCoder) {
		self.price = (aDecoder.decodeObject(forKey: kCorporeItemPriceKey) as! NSNumber).intValue
		self.address = aDecoder.decodeObject(forKey: kCorporeItemAddressKey) as? String
		self.title = aDecoder.decodeObject(forKey: kCorporeItemTitleKey) as? String
		self.followedUserCount = aDecoder.decodeObject(forKey: kCorporeItemFollowedUserCountKey) as? Int
		self.descriptionValue = aDecoder.decodeObject(forKey: kCorporeItemDescriptionValueKey) as? String
		self.bidImages = aDecoder.decodeObject(forKey: kCorporeItemBidImagesKey) as? [String]
		self.type = aDecoder.decodeObject(forKey: kCorporeItemTypeKey) as? String
        self.createTime = (aDecoder.decodeObject(forKey: kCorporeItemCreateTimeKey) as! NSNumber).intValue
        self.telephone = aDecoder.decodeObject(forKey: kCorporeItemTelephoneKey) as! String
    }

    func encode(with aCoder: NSCoder) {
		aCoder.encode(price, forKey: kCorporeItemPriceKey)
		aCoder.encode(address, forKey: kCorporeItemAddressKey)
		aCoder.encode(title, forKey: kCorporeItemTitleKey)
		aCoder.encode(followedUserCount, forKey: kCorporeItemFollowedUserCountKey)
		aCoder.encode(descriptionValue, forKey: kCorporeItemDescriptionValueKey)
		aCoder.encode(bidImages, forKey: kCorporeItemBidImagesKey)
		aCoder.encode(type, forKey: kCorporeItemTypeKey)
        aCoder.encode(createTime, forKey: kCorporeItemCreateTimeKey)
        aCoder.encode(telephone, forKey: kCorporeItemTelephoneKey)
    }

}
