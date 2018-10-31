//
//  NotificationViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 24/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestPopupProtocol {
    
    //outlet
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var blankView: UIView!
    
    //instance variable
    var notificationList = [FriendInfo]()
    var pageNumber: Int = 1
    var totalPage: Int = 1
    var receiverUserInfo = FriendInfo()
    
    //MARK: - UILifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pageNumber = 1
        notificationList.removeAll()
        callAPIToGetNotioficationList(isShowHud: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Helper Methods
    func initialMethods(){
        self.topView.setShadow(radius: 0)

        
    }
    
    //get formatted date string
    func getFormattedDateStringWithDate(date:Date) -> String{
        
        let firstDate = date.getCurrentDateString()
        let yestrdayDate = Date().yesterday.getCurrentDateString()
        let currentDate = Date().getCurrentDateString()
        
        if firstDate == currentDate {
            return self.timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        }else {
            
            if firstDate == yestrdayDate {
                return "Yesterday \(date.getDateStringWithHHAFormat())"
            }else {
                return date.getDateWithDDMMMYYYYHHMMAFormat()
            }
        }
    }
    
    //get suffix for ago from date
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        
        var now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd MMM yyyy hh:mm a"
        let dateString = formatter.string(from: now)
        now = dateString.dateFromString(format: "dd MMM yyyy hh:mm a")! as Date
       
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now as Date) ? date : now as Date
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
    //MARK:- Selector Methods
    @objc func messageBtnAction(sender: UIButton){
        
        let obj = notificationList[sender.tag]
        
        if obj.eventType == "F"{
            let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            receiverUserInfo = obj
            objVC.messageString = "Are you sure want to accept \(obj.fUserFirstName) \(obj.fLastName) request?"
            objVC.isFromRequestSend = false
            objVC.popupDelegate = self
            objVC.isFromApproveReject = false
            objVC.modalPresentationStyle = .overFullScreen
            self.present(objVC, animated: true, completion: nil)
        }else{
            
            let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
            objVC.isFriend = 0
            objVC.profileUserID = obj.fUserID
            objVC.friendRquestStstus = FriendRequestStatus.Unfriend

            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
        }
        
//        if obj.fRequestStatus == "FRIEND"{
//            if obj.quickBloxID.count == 0{
//                showAlert(title: "Warning", message: "Account is not register with QuickBlox", controller: self)
//            }else{
//                APPDELEGATE.createNewDailog(quickBloxId: UInt(obj.quickBloxID)!)
//            }
//        }else if obj.fRequestStatus == "REQ_SENT"{
//
//        }else{
//
//        }
//
//        if obj.fRequestStatus == "FRIEND"{
//
//            if obj.quickBloxID.count == 0{
//                showAlert(title: "Warning", message: "Account is not register with QuickBlox", controller: self)
//            }else{
//                APPDELEGATE.createNewDailog(quickBloxId: UInt(obj.quickBloxID)!)
//            }
//
//
////            let objVC = mainStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
////            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
//
//        }else{
//            let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
//            objVC.isFriend = 0
//            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
//        }
        
    }
    
    //MARK: - Friend Popup Delegate
    func sendFriendRequest(){
        callAPIToAcceptFriendRequest(action: "A")
    }
    
    func rejectFriendrequest() {
        callAPIToAcceptFriendRequest(action: "R")
    }

    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notificationList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        let obj = notificationList[indexPath.row]
        
        cell.titleLabel.text = "\(obj.fUserFirstName) \(obj.fLastName)"
        cell.dayTimeLabel.text = "\(self.getFormattedDateStringWithDate(date: obj.fUpdateAt)) \(obj.notificationMessage)"
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        
        cell.messageBtn.tag = indexPath.row
        cell.messageBtn.addTarget(self, action: #selector(self.messageBtnAction(sender:)), for: .touchUpInside)
        if obj.eventType == "F"{
            cell.messageBtn.setImage(#imageLiteral(resourceName: "friendRequest"), for: .normal)
        }else{
            cell.messageBtn.setImage(#imageLiteral(resourceName: "arrow_right"), for: .normal)
        }
//        if obj.fRequestStatus == "FRIEND"{
//            cell.messageBtn.setImage(#imageLiteral(resourceName: "message"), for: .normal)
//        }else if obj.fRequestStatus == "REQ_SENT"{
//             cell.messageBtn.setImage(#imageLiteral(resourceName: "friendRequest"), for: .normal)
//        }else{
//            cell.messageBtn.setImage(#imageLiteral(resourceName: "arrow_right"), for: .normal)
//        }
        cell.profileImageView.layer.cornerRadius = 25;
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let obj = notificationList[indexPath.row]
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
        objVC.profileUserID = obj.fUserID

        objVC.friendRquestStstus = FriendRequestStatus.Unfriend
        objVC.isFriend = 0
        
//        if obj.fRequestStatus == "FRIEND"{
//            objVC.isFriend = 1
//            objVC.friendRquestStstus = FriendRequestStatus.Friend
//        }else if obj.fRequestStatus == "REQ_SENT"{
//            objVC.friendRquestStstus = FriendRequestStatus.FriendRequestSend
//        }else{
//            objVC.friendRquestStstus = FriendRequestStatus.Unfriend
//            objVC.isFriend = 0
//        }
        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((myTableView.contentOffset.y + myTableView.frame.size.height) >= myTableView.contentSize.height) {
            if pageNumber < totalPage{
                pageNumber += 1
                self.callAPIToGetNotioficationList(isShowHud: true)
            }
        }
    }
    
    //MARK: - Service helper Methods
    func callAPIToGetNotioficationList(isShowHud: Bool){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["page"] = pageNumber as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: isShowHud, params: dictParams , apiName: kGetNotificationList) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                   
                    self.notificationList = FriendInfo.getNotificationList(list: (responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]), notificationList: self.notificationList)
                    
                    if self.notificationList.count > 0{
                        self.blankView.isHidden = true
                    }else{
                        self.blankView.isHidden = false
                    }
                    
                    self.totalPage = responseDict.validatedValue("last_page", expected: 0 as AnyObject) as! Int
                    
                    self.myTableView.reloadData()
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func callAPIToAcceptFriendRequest(action : String){
       
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["another_user_id"] = receiverUserInfo.fUserID as AnyObject
        dictParams["action"] = action as AnyObject
     
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kAcceptApproveFriendRequest) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    //showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                    self.pageNumber = 1
                    self.notificationList.removeAll()
                    self.callAPIToGetNotioficationList(isShowHud: false)
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "Request \(action == "A" ?"accept":"reject") successfully."
                    objVC.isFromRequestSend = true
                    objVC.modalPresentationStyle = .overFullScreen
                    self.present(objVC, animated: true, completion: nil)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    
    //MARK:- Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
