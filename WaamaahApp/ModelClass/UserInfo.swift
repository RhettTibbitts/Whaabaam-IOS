//
//  UserInfo.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class UserInfo: NSObject {

    var emailStr: String = ""
    var passwordStr: String = ""
    var newPasswordStr: String = ""
    var firstNameStr : String = ""
    var lastNameStr : String = ""
    
    var confirmPassword : String = ""
    var location1Str: String = ""
    var location2Str: String = ""
    var fromLocation1Str: String = ""
    var fromLocation2Str: String = ""
    var occupationStr: String = ""
    var workWebsiteStr: String = ""
    var educationStr: String = ""
    var highSchoolStr: String = ""
    var collegeStr: String = ""
    
    var almaMatterStr: String = ""
    var likesStr: String = ""
    var militaryStr: String = ""
    var politicalAffiliationStr: String = ""
    var religionStr: String = ""
    var relationshipStatusStr: String = ""
    var city_id: String = ""

    var name_access: Bool = false
    var email_access: Bool = false
    var phone_access: Bool = false
    var phone_number = ""

    var city_id_access: Bool = false
    var occupation_access: Bool = false
    var work_website_access: Bool = false
    var education_access: Bool = false
    var high_school_access: Bool = false
    var from_city_id_access: Bool = false

   
    var college_access: Bool = false
    var alma_matter_access: Bool = false
    var likes_access: Bool = false
    var military_id_access: Bool = false
    var political_id_access: Bool = false
    var religion_id_access: Bool = false
    var relationship_id_access: Bool = false
    var familyAccess: Bool = false

    var facebookAccess: Bool = false
    var instagramAccess: Bool = false
    var linkdinAccess: Bool = false
    var facebookProfile: String = ""
    var instagramProfile: String = ""
    var linkdinProfile: String = ""
    var twitterProfile: String = ""
    var twitterAccess: Bool = false

    var profileImage : String = ""
    var profileImageList : [Dictionary<String, AnyObject>] = [Dictionary<String, AnyObject>]()
    var fromCityList = [Dictionary<String, AnyObject>]()

    var cityList = [Dictionary<String, AnyObject>]()
    var militaryList = [Dictionary<String, AnyObject>]()
    var politicalList = [Dictionary<String, AnyObject>]()
    var relationshipsList = [Dictionary<String, AnyObject>]()
    var religionList = [Dictionary<String, AnyObject>]()
    var stateList = [Dictionary<String, AnyObject>]()
    var resumeURL : URL!

    
    class func getUserDetailsWithDict(dict:Dictionary<String, AnyObject>) -> UserInfo{
        
        let userInfo = UserInfo()
        userInfo.fromCityList = dict.validatedValue("from_cities", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.cityList = dict.validatedValue("cities", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.militaryList = dict.validatedValue("militaries", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.politicalList = dict.validatedValue("politicals", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.relationshipsList = dict.validatedValue("relationships", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.religionList = dict.validatedValue("religions", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.stateList = dict.validatedValue("states", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        
        let userDict = dict.validatedValue("user", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
        
        userInfo.almaMatterStr = userDict.validatedValue("alma_matter", expected: "" as AnyObject) as! String
        userInfo.alma_matter_access = (userDict.validatedValue("alma_matter_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.location2Str = userDict.validatedValue("city_id", expected: "" as AnyObject) as! String
        userInfo.city_id_access = (userDict.validatedValue("city_id_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.collegeStr = userDict.validatedValue("college", expected: "" as AnyObject) as! String
        userInfo.college_access = (userDict.validatedValue("college_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.educationStr = userDict.validatedValue("education", expected: "" as AnyObject) as! String
        userInfo.education_access = (userDict.validatedValue("education_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.emailStr = userDict.validatedValue("email", expected: "" as AnyObject) as! String
        userInfo.email_access = (userDict.validatedValue("email_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.firstNameStr = userDict.validatedValue("first_name", expected: "" as AnyObject) as! String
        userInfo.highSchoolStr = userDict.validatedValue("high_school", expected: "" as AnyObject) as! String
        userInfo.high_school_access = (userDict.validatedValue("high_school_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.lastNameStr = userDict.validatedValue("last_name", expected: "" as AnyObject) as! String
        userInfo.likesStr = userDict.validatedValue("likes", expected: "" as AnyObject) as! String
        userInfo.militaryStr = userDict.validatedValue("military_id", expected: "" as AnyObject) as! String
        userInfo.military_id_access = (userDict.validatedValue("military_id_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.occupationStr = userDict.validatedValue("occupation", expected: "" as AnyObject) as! String
        userInfo.occupation_access = (userDict.validatedValue("occupation_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.politicalAffiliationStr = userDict.validatedValue("political_id", expected: "" as AnyObject) as! String
        userInfo.likes_access = (userDict.validatedValue("likes_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.political_id_access = (userDict.validatedValue("political_id_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.relationshipStatusStr = userDict.validatedValue("relationship_id", expected: "" as AnyObject) as! String
        userInfo.relationship_id_access = (userDict.validatedValue("relationship_id_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.religionStr = userDict.validatedValue("religion_id", expected: "" as AnyObject) as! String
        userInfo.religion_id_access = (userDict.validatedValue("religion_id_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.location1Str = userDict.validatedValue("state_id", expected: "" as AnyObject) as! String
        userInfo.workWebsiteStr = userDict.validatedValue("work_website", expected: "" as AnyObject) as! String
        userInfo.work_website_access = (userDict.validatedValue("work_website_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.profileImage = (userDict.validatedValue("image", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String
        userInfo.profileImageList = userDict.validatedValue("images", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        userInfo.name_access = (userDict.validatedValue("last_name_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.familyAccess = (userDict.validatedValue("family_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.facebookAccess = (userDict.validatedValue("fb_link_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.instagramAccess = (userDict.validatedValue("insta_link_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.twitterAccess = (userDict.validatedValue("twit_link_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.twitterProfile = userDict.validatedValue("twit_link", expected: "" as AnyObject) as! String
        userInfo.linkdinAccess = (userDict.validatedValue("linked_in_link_access", expected: "" as AnyObject) as! String).toBool()
        userInfo.linkdinProfile = userDict.validatedValue("linked_in_link", expected: "" as AnyObject) as! String
        
        userInfo.facebookProfile = userDict.validatedValue("fb_link", expected: "" as AnyObject) as! String
        userInfo.instagramProfile = userDict.validatedValue("insta_link", expected: "" as AnyObject) as! String
        userInfo.resumeURL = URL.init(string: userDict.validatedValue("resume", expected: "" as AnyObject) as! String)
        userInfo.phone_number = userDict.validatedValue("phone", expected: "" as AnyObject) as! String
        userInfo.phone_access = (userDict.validatedValue("phone_access", expected: "" as AnyObject) as! String).toBool()

        userInfo.fromLocation1Str = userDict.validatedValue("from_state_id", expected: "" as AnyObject) as! String
        userInfo.fromLocation2Str = userDict.validatedValue("from_city_id", expected: "" as AnyObject) as! String
        userInfo.from_city_id_access = (userDict.validatedValue("from_city_id_access", expected: "" as AnyObject) as! String).toBool()
        
        return userInfo
    }
}




//"political_id": 1,
//"political_id_access": 1,
//"religion_id": 1,
//"religion_id_access": 1,
//"relationship_id": 1,
//"relationship_id_access": 1,

