//
//  FriendInfo.swift
//  WaamaahApp
//
//  Created by Ashish on 06/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class FriendInfo: NSObject {

    var fAddress: String = ""
    var fCapturedUserID: String = ""
    var fID: String = ""
    var fLattitude: String = ""
    var fLongitude: String = ""
    var fRequestStatus: String = ""
    var fUserFirstName: String = ""
    var fUserID: String = ""
    var fUserImage: String = ""
    var fLastName: String = ""
    var fUpdateAt: Date = Date()
    
    var fFriendrequestID: String = ""
    var fFriendUserID: String = ""
    var notificationID: String = ""
    var eventType:String = ""
    var notificationMessage:String = ""
    var userID:String = ""
    var relationStr:String = ""
    var otherRelationDetails:String = ""
    var familyRelationID:String = ""
    var anotherUserID:String = ""
    var friendRequestID:String = ""
    var quickBloxID: String = ""
    var eventID:String = ""

    class func getCloseFriendList(list:[Dictionary<String, AnyObject>], friendList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = friendList
        
        for dict in list{
            let obj = FriendInfo()
            obj.fAddress = dict.validatedValue("address", expected: "" as AnyObject) as! String
            obj.fCapturedUserID = dict.validatedValue("capture_user_id", expected: "" as AnyObject) as! String
            obj.fID = dict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fLattitude = dict.validatedValue("lat", expected: "" as AnyObject) as! String
            obj.fLongitude = dict.validatedValue("lng", expected: "" as AnyObject) as! String
            obj.fRequestStatus = dict.validatedValue("req_status", expected: "" as AnyObject) as! String
            obj.fUpdateAt =  (dict.validatedValue("updated_at", expected: "" as AnyObject) as! String).dateFromString(format: "yyyy-MM-dd HH:mm:ss")! as Date
            let userDict = dict.validatedValue("user_info", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
            
            obj.fUserFirstName = userDict.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = userDict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fUserImage = (userDict.validatedValue("image", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String
            obj.fLastName = userDict.validatedValue("last_name", expected: "" as AnyObject) as! String
            obj.quickBloxID = userDict.validatedValue("quickblox_id", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        
        return tempList
    }
    
    class func getConnectionFriendList(list:[Dictionary<String, AnyObject>], friendList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = friendList
        
        for dict in list{
            let obj = FriendInfo()
            obj.fUserFirstName = dict.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = dict.validatedValue("friend_user_id", expected: "" as AnyObject) as! String
            obj.fUserImage = "\(dict.validatedValue("thumb_path", expected: "" as AnyObject) as! String)/\(dict.validatedValue("image", expected: "" as AnyObject) as! String)"
            obj.fLastName = dict.validatedValue("last_name", expected: "" as AnyObject) as! String
            obj.fAddress = dict.validatedValue("address", expected: "" as AnyObject) as! String
            obj.fFriendrequestID = dict.validatedValue("friend_request_id", expected: "" as AnyObject) as! String
            obj.quickBloxID = dict.validatedValue("quickblox_id", expected: "" as AnyObject) as! String
           
            let date = dict.validatedValue("time", expected: "" as AnyObject) as! String
            if date.count > 1{
                obj.fUpdateAt = (dict.validatedValue("time", expected: "" as AnyObject) as! String).dateFromString(format: "yyyy-MM-dd HH:mm:ss")! as Date
            }
            
            tempList.append(obj)
        }
        
        return tempList
    }

    class func getNotificationList(list:[Dictionary<String, AnyObject>], notificationList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = notificationList
        
        for dict in list{
            let obj = FriendInfo()
           
            obj.fUpdateAt =  (dict.validatedValue("created_at", expected: "" as AnyObject) as! String).dateFromString(format: "yyyy-MM-dd HH:mm:ss")! as Date
            obj.notificationID = dict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.eventType = dict.validatedValue("event_type", expected: "" as AnyObject) as! String
            obj.notificationMessage = dict.validatedValue("message", expected: "" as AnyObject) as! String
            obj.fRequestStatus = dict.validatedValue("req_status", expected: "" as AnyObject) as! String
            obj.fUserID = dict.validatedValue("profile_user_id", expected: "" as AnyObject) as! String
            obj.eventID = dict.validatedValue("event_id", expected: "" as AnyObject) as! String
            obj.eventType = dict.validatedValue("event_type", expected: "" as AnyObject) as! String
            
            let connectedUser = dict.validatedValue("concerned_user", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
            
            obj.fUserFirstName = connectedUser.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = connectedUser.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fUserImage = (connectedUser.validatedValue("image", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String
            obj.fLastName = connectedUser.validatedValue("last_name", expected: "" as AnyObject) as! String
            obj.quickBloxID = connectedUser.validatedValue("quickblox_id", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        
        return tempList
    }
    
    class func getFamilyMemberlist(list:[Dictionary<String, AnyObject>], familyList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = familyList
        
        for dict in list{
            let obj = FriendInfo()
           
            obj.relationStr = (dict.validatedValue("relation", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("name", expected: "" as AnyObject) as! String
            obj.otherRelationDetails = dict.validatedValue("other_relation_detail", expected: "" as AnyObject) as! String
            obj.anotherUserID = dict.validatedValue("another_user_id", expected: "" as AnyObject) as! String
            obj.familyRelationID = dict.validatedValue("family_relation_id", expected: "" as AnyObject) as! String
            obj.friendRequestID = dict.validatedValue("friend_req_id", expected: "" as AnyObject) as! String

            obj.userID = dict.validatedValue("user_id", expected: "" as AnyObject) as! String
            
            let connectedUser = dict.validatedValue("user_info", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
            
            obj.fUserFirstName = connectedUser.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = connectedUser.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fUserImage = connectedUser.validatedValue("image", expected: "" as AnyObject) as! String
            obj.fLastName = connectedUser.validatedValue("last_name", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        
        return tempList
    }
    
    class func getUnFamilyMemberlist(list:[Dictionary<String, AnyObject>], familyList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = familyList
        
        for dict in list{
            let obj = FriendInfo()
            obj.anotherUserID = dict.validatedValue("friend_user_id", expected: "" as AnyObject) as! String
            obj.friendRequestID = dict.validatedValue("friend_req_id", expected: "" as AnyObject) as! String
            obj.fUserFirstName = dict.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = dict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fUserImage = "\(dict.validatedValue("image_path", expected: "" as AnyObject) as! String)/\(dict.validatedValue("image", expected: "" as AnyObject) as! String)"
            obj.fLastName = dict.validatedValue("last_name", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        
        return tempList
    }
    
    class func getMutualContactlist(list:[Dictionary<String, AnyObject>], familyList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = familyList
        
        for dict in list{
            let obj = FriendInfo()
            obj.anotherUserID = dict.validatedValue("friend_user_id", expected: "" as AnyObject) as! String
            obj.friendRequestID = dict.validatedValue("friend_req_id", expected: "" as AnyObject) as! String
            obj.fUserFirstName = dict.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = dict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fUserImage = "\(dict.validatedValue("image_path", expected: "" as AnyObject) as! String)/\(dict.validatedValue("image", expected: "" as AnyObject) as! String)"
            obj.fLastName = dict.validatedValue("last_name", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        
        return tempList
    }
    
    class func getMutualFamilylist(list:[Dictionary<String, AnyObject>], familyList:[FriendInfo]) -> [FriendInfo]{
        
        var tempList = familyList
        for dict in list{
            let obj = FriendInfo()
            let userDict = dict.validatedValue("user_info", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
            
            obj.anotherUserID = dict.validatedValue("another_user_id", expected: "" as AnyObject) as! String
            obj.friendRequestID = dict.validatedValue("friend_req_id", expected: "" as AnyObject) as! String
            obj.fUserFirstName = userDict.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = userDict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fUserImage = "\(userDict.validatedValue("image_path", expected: "" as AnyObject) as! String)/\(userDict.validatedValue("image", expected: "" as AnyObject) as! String)"
            obj.fLastName = userDict.validatedValue("last_name", expected: "" as AnyObject) as! String
            obj.relationStr = (dict.validatedValue("relation", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("name", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        return tempList
    }
    
    class func getSearchFriendList(list: [Dictionary<String,AnyObject>], existingList:[FriendInfo]) ->[FriendInfo]{
        
        var tempList = existingList
        
        for dict in list {
            let obj = FriendInfo()
            let userDict = dict.validatedValue("user_info", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>
            obj.fUserFirstName = userDict.validatedValue("first_name", expected: "" as AnyObject) as! String
            obj.fUserID = userDict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.fLastName = userDict.validatedValue("last_name", expected: "" as AnyObject) as! String
            obj.fRequestStatus = dict.validatedValue("req_status", expected: "" as AnyObject) as! String
            obj.fUserImage = (userDict.validatedValue("last_name", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("org", expected: "" as AnyObject) as! String
            obj.quickBloxID = userDict.validatedValue("quickblox_id", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        return tempList
    }
    
    
}
