//
//  NetworkManager.swift
//  AutoWeather
//
//  Created by Shady Gabal on 11/18/16.
//  Copyright © 2016 Shady Gabal. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkManager: NSObject {

    static let sharedInstance = NetworkManager()
    
    var manager: AFURLSessionManager

    public enum NetworkMethod:String{
        case POST
        case GET
        case PUT
        case DELETE
    }
    
    override init(){
        let configuration = URLSessionConfiguration.default
        self.manager = AFURLSessionManager(sessionConfiguration: configuration)
        super.init()
    }
    
    
    public func networkRequest(urlString: String, method: NetworkMethod, parameters: Dictionary<String, Any?>, successCallback : @escaping (Any?) -> Void, errorCallback: @escaping (Int) -> Void){
        
        var error:NSError?
        
        var params = parameters
        params["uuid"] = Globals.uuid()
        
        if let secret_key = Globals.secretKey() {
            params["secret_key"] = secret_key
        }
        
        let request:NSURLRequest = AFHTTPRequestSerializer().request(withMethod: method.rawValue, urlString: urlString, parameters: params as NSDictionary, error: &error)
        
        func callback(response:URLResponse, responseObject:Any?, error:Error?) -> Void {
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            
            if error != nil || statusCode >= 400{
                print(error)
                errorCallback(statusCode)
                
            }
            else{
                successCallback(responseObject)
            }
            
        }
        
        let dataTask = self.manager.dataTask(with: request as URLRequest, completionHandler: callback)
        dataTask.resume()
        
    }


}
