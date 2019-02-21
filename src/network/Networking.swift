//
//  Networking.swift
//  dakuofu
//
//  Created by HamGuy on 8/31/16.
//  Copyright © 2016 HamGuy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


public enum Result<T> {
    case fail(Error)
    case success(T)
}


public let alamofireManager: Manager = {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
    let alamofireManager = Alamofire.Manager(configuration: configuration)
    
    return alamofireManager
}()

public enum NetworkingError: Error {
    
    case invalidRespondData
    case networkError
    case unknowError
    case invalidRequest
    case resourceNonExist
    case veryfiCodeError
    case requestIsRunning
    case nilSelf
    case nilRespondItems
    case dumplicatePhone
    case dumplicateAccount
    case invalidGrant
}

extension NetworkingError: RawRepresentable {
    
     public init?(rawValue: Int) {
        switch rawValue {
        case 1:
            self = .invalidRespondData
        case 2:
            self = .networkError
        case 3:
            self = .unknowError
        case 4:
            self = .requestIsRunning
        case 5:
            self = .nilSelf
        case 6:
            self = .nilRespondItems
        case 403:
            self = .invalidRequest
        case 404:
            self = .resourceNonExist
        case 101:
            self = .veryfiCodeError
        case 102:
            self = .dumplicatePhone
        case 103:
            self = .dumplicateAccount
        case 400:
            self = .invalidGrant
        default:
            self = .unknowError
        }
    }
    
     public var rawValue: Int {
        switch self {
        case .invalidRespondData:
            return 1
        case .networkError:
            return 2
        case .unknowError:
            return 3
        case .requestIsRunning:
            return 4
        case .nilSelf:
            return 5
        case .nilRespondItems:
            return 6
        case .invalidRequest:
            return 403
        case .resourceNonExist:
            return 404
        case .veryfiCodeError:
            return 101
        case .dumplicatePhone:
            return 102
        case .dumplicateAccount:
            return 103
        case .invalidGrant:
            return 400
        }
    }
}

 extension NetworkingError: CustomStringConvertible {
    
     public var description: String {
        switch self {
        case .invalidRespondData: return "无效数据"
        case .networkError: return "网络连接失败，请检查网络设置"
        case .invalidRequest: return "无效请求"
        case .resourceNonExist: return "资源不存在"
        case .veryfiCodeError: return "验证码错误"
        case .unknowError: return "本次操作失败，请稍后再试"
        case .requestIsRunning: return "请求已发送，请稍后"
        case .nilSelf: return "请求对象已被释放"
        case .nilRespondItems: return "items 中不存在有效数据"
        case .dumplicateAccount: return "用户名已被注册"
        case .dumplicatePhone: return "手机号已被注册"
        case .invalidGrant: return "授权失败，用户名或密码错误"
        }
    }
}


public protocol APIType {
    
    associatedtype ResultType
    
    /// 无实现，应由子集的 APIType 实现
    var baseURL: String { get }
    /// 无实现
    var path: String { get }
    /// 默认实现 = baseURL + path
    var url: String { get }
    /// 无实现
    var method: Alamofire.Method { get }
    /// 默认空实现
    var parameters: [String:AnyObject]? { get }
    /// 默认实现 `ParameterEncoding.URL`
    var encoding: ParameterEncoding { get }
    /// 默认空实现
    var headers: [String : String] { get }
    
    func handleJSON(_ json: JSON) -> Result<ResultType>
}

 protocol ImageAPIType: APIType {
    
    var fileName: String { get }
    var image: UIImage { get }
    var compressionQuality: CGFloat { get }
}


 extension APIType {
    
    var url: String {
        return baseURL + path
    }
    
    var parameters: [String:AnyObject]? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return .URL
    }
    
    var headers: [String : String] {
        if let token = UserContext.sharedContext.token{
            return ["Authorization":"Bearer \(token.access_token)"]
        }
        return [:]
    }
}

extension Alamofire.Request {
    
    public func responseJSONResult(_ completionHandler: (Result<JSON>) -> Void) -> Self {
        
        return responseJSON { response in
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                var result: Result<JSON>
                switch response.result {
                case .Success(let object):
                    result = Result.success(JSON(object))
                    if let httpResponse = response.response {
                        if !(200..<300 ~= httpResponse.statusCode){
                            var statusCode = httpResponse.statusCode
                            let json = JSON(object)
                            if let code = json["code"].int , statusCode == 406{
                                statusCode = code
                            }
                            result = Result.fail(NetworkingError(rawValue: statusCode)!)
                        }
                    }
                case .Failure(let error):
                    result = Result.fail(error)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(result)
                    
                }
            }
        }
    }
}

func hg_request<T: APIType>(_ api: T, completion: @escaping (Result<T.ResultType>) -> Void) -> Request {
    
    return alamofireManager.request(api.method, api.url, parameters: api.parameters, encoding: api.encoding, headers: api.headers).responseJSONResult { result in
        switch result {
        case .fail(let error):
            completion(Result.fail(error))
        case .success(let json):
            completion(api.handleJSON(json))
        }
    }
}

