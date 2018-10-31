//
//  AnalyticsHelper.swift
//  MeClub
//
//  Created by Ashish Kumar singh on 03/08/18.
//  Copyright © 2017 Xicom All rights reserved.
//

import UIKit
import Alamofire


final class AnalyticsHelper: NSObject {
    class var sharedInstance: AnalyticsHelper {
        
        struct Static {
            static let instance = AnalyticsHelper()
        }
        return Static.instance
    }
    
//    func getDataContent(page:String,hier:String,subSection:String,subSection2:String,contentType:String,newVisitors:String,previousPage:String,percentageOfPageViewed:String,loginStatus:Bool,customPageNames:String,userType:String)-> Dictionary<String,Any>  {
//
//        return ["mcs.sdk4.pagename":page ,"mcs.sdk4.channel":"sg:meclub:mobileiphone" ,"mcs.sdk4.hier1":hier ,"mcs.sdk4.server": "meclub ios" , "s.visitorNamespace": "mediacorp" ,"mcs.sdk4.division" : "sg" ,"mcs.sdk4.site": "meclub" , "mcs.sdk4.sitesection" : "sg:meclub:mobileaiphone" , "mcs.sdk4.subsection" : subSection ,"mcs.sdk4.subsection2" : subSection2 , "mcs.sdk4.contenttype":contentType , "mcs.sdk4.newrepeat" : newVisitors ,   "mcs.sdk4.previouspage": previousPage ,"mcs.sdk4.loginstatus" :loginStatus ,"mcs.sdk4.sitelanguage" : "en" , "mcs.sdk4.mobiledeviceid":  String(describing: APPDELEGATE.deviceID!),"mcs.sdk4.custompagename": customPageNames , "mcs.sdk4.lotameid" : String(describing: APPDELEGATE.lotameID!) ,"mcs.sdk4.cxenseid" : String(describing: APPDELEGATE.cxenseID!),"mcs.sdk4.ssoid" : ((UserDefaults.standard.value(forKey: "UUID")) != nil) ? String(describing: (UserDefaults.standard.value(forKey: "UUID"))!) : "","mcs.sdk4.uid" : (UserDefaults.standard.value(forKey: kSSOID)) != nil ? String(describing: (UserDefaults.standard.value(forKey: kSSOID))!) : "","mcs.sdk4.usertype":userType ,"mcs.sdk4.gender" : (UserDefaults.standard.value(forKey: kGENDER)) != nil ? String(describing: (UserDefaults.standard.value(forKey: kGENDER))!) : "Male",  "mcs.sdk4.age":(UserDefaults.standard.value(forKey: kAGE)) != nil ? String(describing: (UserDefaults.standard.value(forKey: kAGE))!) : "18","mcs.sdk4.daytype" : Date().checkWeekDayORWeekendFromDay() , "mcs.sdk4.dayofweek" : Date().getWeekDayFromDay() ,"mcs.sdk4.hourofday" : Date().getTimeFromDay()]
//
//    }
    
    
    func callAPIToGetUDID() {
        let url = "https://uid.mediacorp.sg/api/Profiles/GetUID?LotameID=&CxenseID=&SSOID=&UniversalID%@&DeviceID="
        Alamofire.request(URL.init(string: url)!, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success(_):
              UserDefaults.standard.setValue(response.result.value as AnyObject?, forKey: "UUID")
            case .failure(_):
                logInfo(message: "\nfailure:\n failure Response From Server >>>>>>\n\(String(describing: response.result.error))")
                UserDefaults.standard.setValue("", forKey: "UUID")
            }
        }
    }
    
}
