//
//  BidApi.swift
//  dakuofu
//
//  Created by HamGuy on 9/5/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension BidApi{
    struct RecommendBids {
        
    }
    
    struct FavoriteBids: BidApiType {
        //api/users/1/favoriteBids
        
        let id: String
        
        init(id: String){
            self.id = id
        }
        
        var method: Alamofire.Method{
            return .GET
        }
        
        var path: String{
            return "api/users/\(id)/favoriteBids"
        }
        
        func handleJSON(_ json: JSON) -> Result<([CorporeItem], Bool)> {
            
            let listResult = listResponseData(json)
            switch listResult {
            case let .fail(error):
                return Result.fail(error)
            case let .success(_, items, isEnd):
                var bids: [CorporeItem] = []
                if let array = items.array{
                    for item in array{
                        bids.append(CorporeItem(json: item))
                    }
                }
                let result = (bids, isEnd)
                return Result.success(result)
            }
        }
    }
    
    /**
     *  标的详情
     */
    struct BidInfo: BidApiType {
        let id: String
        
        init(id: String){
            self.id = id
        }
        
        var method: Alamofire.Method{
            return .GET
        }
        
        var path: String{
            return "api/bids/\(id)"
        }
        
        func handleJSON(_ json: JSON) -> Result<CorporeItem> {
            return Result.success(CorporeItem(json: json))
        }
    }
    
    
    /**
     *  标的搜索
     */
    struct SearchBid: BidApiType {
        enum SearcType: String {
            case type = "findByType"
            case userCount = "findUserCount"
            case title = "findByTitle"
            case keyword = "findByKeyword"
        }
        
        let page: Int
        let size: Int
        let sort: SortType?
        let keyword:String?
        let followType: FollowType?
        let searchType: SearcType
        let title: String?
        
        init(searchType: SearcType, type: FollowType? = nil, page :Int = 0, size :Int = 10, sort :SortType? = nil, keyword: String? = nil, title: String? = nil ){
            self.searchType = searchType
            self.page = page
            self.size = size
            self.sort = sort
            self.keyword = keyword
            self.followType = type
            self.title = title
        }
        
        var method: Alamofire.Method{
            return .GET
        }
        
        var path: String{
            return "api/bids/search/\(searchType.rawValue)"
        }
        
        var parameters: [String : AnyObject]?{
            var paras: [String : AnyObject] = [:]
            switch searchType {
            case .type:
                paras["type"] = followType!.rawValue as AnyObject?
            case .userCount:
                return nil
            case .title:
                paras["title"] = title! as AnyObject?
            case .keyword:
                paras["keyword"] = keyword! as AnyObject?
                if let type = followType{
                    paras["type"] = type.rawValue as AnyObject?
                }
            }
            paras["page"] = page as AnyObject?
            paras["size"] = size as AnyObject?
            
            if let sortType = sort{
                paras["sort"] = sortType.rawValue as AnyObject?
            }
            
            return paras
        }
        
        func handleJSON(_ json: JSON) -> Result<([CorporeItem], Bool)> {
            
            let listResult = listResponseData(json)
            switch listResult {
            case let .fail(error):
                return Result.fail(error)
            case let .success(_, items, isEnd):
                var bids: [CorporeItem] = []
                if let array = items.array{
                    for item in array{
                        bids.append(CorporeItem(json: item))
                    }
                }
                let result = (bids, isEnd)
                return Result.success(result)
            }
        }
    }
    
    
    /**
     *  添加收藏
     */
    struct AddFavorite: BidApiType {
        let itemId: String
        
        init(id:String){
            self.itemId = id
        }
        
        var method: Alamofire.Method{
            return .PATCH
        }
        
        var path: String{
            return "api/users/\(UserContext.sharedContext.userId!)/favoriteBids"
        }
        
        var headers: [String : String]{
            return ["Content-Type":"text/uri-list","Authorization":"Bearer \(UserContext.sharedContext.token!.access_token)"]
        }
        
//        var encoding: ParameterEncoding{
//            let custom: (URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) = { (convertible, params) in
//                let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
////                mutableRequest.HTTPBody = "\(self.baseURL)api/bids/\(self.itemId)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//                mutableRequest.HTTPBody = "http://localhost:8080/api/bids/\(self.itemId)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//                return (mutableRequest, nil)
//            }
//            
//            return .Custom(custom)
//        }
        
        func handleJSON(_ json: JSON) -> Result<JSON> {
            return Result.success(json)
        }
        
        func sendRequest(_ completion:@escaping (_ success:Bool)->Void) {
            /* Configure session, choose between:
             * defaultSessionConfiguration
             * ephemeralSessionConfiguration
             * backgroundSessionConfigurationWithIdentifier:
             And set session-wide properties, such as: HTTPAdditionalHeaders,
             HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
             */
            let sessionConfig = URLSessionConfiguration.default
            
            /* Create session, and optionally set a NSURLSessionDelegate. */
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            /* Create the Request:
             http://114.55.178.232/api/users/1/favoriteBids (PUT http://114.55.178.232/api/users/48/favoriteBids)
             */
            
            guard let URL = URL(string: self.url) else {return}
            let request = NSMutableURLRequest(url: URL)
            request.httpMethod = "PATCH"
            
            // Headers
            
            request.addValue("Bearer \(UserContext.sharedContext.token!.access_token)", forHTTPHeaderField: "Authorization")
            request.addValue("text/uri-list", forHTTPHeaderField: "Content-Type")
            
            // Body
            
            let bodyString = "\(self.baseURL)api/bids/\(self.itemId)"
            request.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
            
            /* Start a new Task */
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    debugPrint("URL Session Task Succeeded: HTTP \(statusCode)")
                    completion(success: true)
                }
                else {
                    // Failure
                    completion(success: false)
                    debugPrint("URL Session Task Failed: %@", error!.localizedDescription);
                }
            })
            task.resume()
            session.finishTasksAndInvalidate()
        }

    }
    
    struct RemoveFavorites: BidApiType {
        let itemIds: [String]
        
        init(ids:[String]){
            self.itemIds = ids
        }
        
        var method: Alamofire.Method{
            return .PUT
        }
        
        var path: String{
            return "api/users/\(UserContext.sharedContext.userId!)/favoriteBids"
        }
        
        var headers: [String : String]{
            return ["Content-Type":"text/uri-list","Authorization":"Bearer \(UserContext.sharedContext.token!.access_token)"]
        }
        
        var encoding: ParameterEncoding{
            let custom: (URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) = {
                (URLRequest, parameters) in
                let mutableURLRequest =  NSMutableURLRequest(URL: NSURL(string: self.url)!)
                mutableURLRequest.setValue("text/uri-list", forHTTPHeaderField: "Content-Type")
                var bodyString = ""
                for id in self.itemIds{
                    bodyString += "\(self.baseURL)api/bids/\(id)\n"
                }
                let body = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
                mutableURLRequest.HTTPBody = body
                
                return (mutableURLRequest, nil)
            }
            
            return .Custom(custom)
        }
        
        func handleJSON(_ json: JSON) -> Result<JSON> {
            return Result.success(json)
        }
        
        func sendRequest(_ completion:@escaping (_ success:Bool)->Void) {
            /* Configure session, choose between:
             * defaultSessionConfiguration
             * ephemeralSessionConfiguration
             * backgroundSessionConfigurationWithIdentifier:
             And set session-wide properties, such as: HTTPAdditionalHeaders,
             HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
             */
            let sessionConfig = URLSessionConfiguration.default
            
            /* Create session, and optionally set a NSURLSessionDelegate. */
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            /* Create the Request:
             http://114.55.178.232/api/users/1/favoriteBids (PUT http://114.55.178.232/api/users/48/favoriteBids)
             */
            
            guard let URL = URL(string: self.url) else {return}
            let request = NSMutableURLRequest(url: URL)
            request.httpMethod = "PUT"
            
            // Headers
            
            request.addValue("Bearer \(UserContext.sharedContext.token!.access_token)", forHTTPHeaderField: "Authorization")
            request.addValue("text/uri-list", forHTTPHeaderField: "Content-Type")
            
            // Body
            
            var bodyString = "" 
            for id in self.itemIds{
                bodyString += "\(self.baseURL)api/bids/\(id)\n"
            }
            
            request.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
            
            /* Start a new Task */
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    debugPrint("URL Session Task Succeeded: HTTP \(statusCode)")
                    completion(success: true)
                }
                else {
                    // Failure
                    completion(success: false)
                    debugPrint("URL Session Task Failed: %@", error!.localizedDescription);
                }
            })
            task.resume()
            session.finishTasksAndInvalidate()
        }
    }
}
