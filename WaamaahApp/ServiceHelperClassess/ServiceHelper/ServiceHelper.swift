//
//  ServiceHelper.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 03/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import Foundation
import Alamofire
import UIKit

final class ServiceHelper {
   
    //staging
    //let baseURL =  "http://dev2.xicom.us/whabam/api/"
    //production
    let baseURL =  "http://whaabaam.com/backend/api/"
    
    // Specifying the Headers we need
    class var sharedInstance: ServiceHelper {
        
        struct Static {
            static let instance = ServiceHelper()
        }
        return Static.instance
    }
    
    //Create Post and send request
    func createPostRequest(isShowHud: Bool, params: [String : AnyObject]!,apiName : String, completion: @escaping (_ response: AnyObject?, _ error: NSError?) -> Void)
    {
        
        if !APPDELEGATE.checkReachablility() {
            completion(nil,NSError.init(domain: "Please check your internet connection!", code: 000, userInfo: nil))
            return
        }
        if isShowHud {
            showHud()
        }
        
        let url = self.baseURL + apiName
        let parameterDict = params as NSDictionary
        

        var headers = HTTPHeaders()
        if UserDefaults.standard.value(forKey: kAccessToken) != nil {
            headers = [kAccessToken: UserDefaults.standard.value(forKey: kAccessToken) as! String, "contentType" : "application/json"]
        }
        logInfo(message: "\n\n Token  >>>>>>\(headers)")
        logInfo(message: "\n\n Request URL  >>>>>>\(url)")
        logInfo(message: "\n\n Request Parameters >>>>>>\n\(parameterDict)")
        Alamofire.request(URL.init(string: url)!, method: HTTPMethod.post, parameters: parameterDict as? Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                logInfo(message: "\nsuccess:\n Response From Server >>>>>>\n\(response)")
                RappleActivityIndicatorView.stopAnimation()
                RappleActivityIndicatorView.stopAnimation()
                RappleActivityIndicatorView.stopAnimation()
                completion(response.result.value as AnyObject?, nil)
            case .failure(_):
                logInfo(message: "\nfailure:\n failure Response From Server >>>>>>\n\(String(describing: response.result.error))")
                RappleActivityIndicatorView.stopAnimation()
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    
    //Create Get and send request
    func createGetRequest(isShowHud: Bool, params: [String : AnyObject]!,apiName : String, completion: @escaping (_ response: AnyObject?, _ error: NSError?) -> Void) {
        
        if !APPDELEGATE.checkReachablility() {
            completion(nil,NSError.init(domain: "Please check your internet connection!", code: 000, userInfo: nil))
            return
        }
        if isShowHud {
            showHud()
        }
        let url = self.baseURL + apiName
       
        
     
        let parameterDict = params as Dictionary
        var headers = HTTPHeaders()
        if UserDefaults.standard.value(forKey: kAccessToken) != nil {
            headers = [kAccessToken: UserDefaults.standard.value(forKey: kAccessToken) as! String, "contentType" : "application/json"]
        }
        logInfo(message: "\n\n Token  >>>>>>\(headers)")
        logInfo(message: "\n\n Request URL  >>>>>>\(url)")
        logInfo(message: "\n\n Request Parameters >>>>>>\n\(parameterDict)")
        
        Alamofire.request(URL.init(string: url)!, method: HTTPMethod.get, parameters: parameterDict, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                logInfo(message: "\nsuccess:\n Response From Server >>>>>>\n\(response)")
                RappleActivityIndicatorView.stopAnimation()
                completion(response.result.value as AnyObject?, nil)
            case .failure(_):
                logInfo(message: "\nfailure:\n failure Response From Server >>>>>>\n\(String(describing: response.result.error))")
                RappleActivityIndicatorView.stopAnimation()
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    func createRequestToUploadDataWithString(additionalParams : Dictionary<String,Any>,dataContent : Data?,strName : String,strFileName : String,strType : String ,apiName : String,completion: @escaping (_ response: AnyObject?, _ error: NSError?) -> Void) {
        if !APPDELEGATE.checkReachablility() {
            completion(nil,NSError.init(domain: "Please check your internet connection!", code: 000, userInfo: nil))
            return
        }
        self.showHud()
        let url = self.baseURL + apiName
        
        var headers = HTTPHeaders()
        if UserDefaults.standard.value(forKey: kAccessToken) != nil {
           headers = ["Content-Type" : "multipart/form-data", kAccessToken: UserDefaults.standard.value(forKey: kAccessToken) as! String]
        } else {
            headers = ["Content-Type" : "multipart/form-data"]
        }
        logInfo(message: "\n\n Token  >>>>>>\(headers)")
        logInfo(message: "\n\n Request URL  >>>>>>\(url)")
        logInfo(message: "\n\n Parameter >>>> \(additionalParams)")
        let URL = try! URLRequest(url: url, method: .post, headers: headers)
        
        Alamofire.upload(multipartFormData: { (multipartData) in
            for (key,value) in additionalParams {
                multipartData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            if dataContent != nil {
                multipartData.append(dataContent!, withName:strName, fileName: strFileName, mimeType: strType)
            }
        }, with: URL) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    RappleActivityIndicatorView.stopAnimation()
                    completion(response.result.value as AnyObject?, nil)
                }
                break
            case .failure(let encodingError):
                RappleActivityIndicatorView.stopAnimation()
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .none, completionLabel: "", completionTimeout: 1.0)
                completion(nil, encodingError as NSError?)
                break
            }
        }
    }
    
    func showHud() {
        let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
        RappleActivityIndicatorView.startAnimating(attributes: attribute)
    }
}
