//
//  FamilyMemberListViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 15/10/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class SearchCloseFrinedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RequestPopupProtocol {
    
    //MARK:- Outlet and Instance Variables
    @IBOutlet weak var mytableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var familyList = [FriendInfo]()
    var pageNumber: Int = 1
    var totalPage: Int = 1
    var receiverUserInfo = FriendInfo()
    var searchString = ""
    
    //MARK:- UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialMethods()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        familyList.removeAll()
        pageNumber = 1
        totalPage = 1
        self.searchContainerView.layer.cornerRadius = 4
        self.callAPIToSearchUser()
    }
    
    //MARK:- Helper Methods
    func initialMethods(){
        
        topView.setShadow(radius: 0)
        
    }
    
    //MARK: - UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.familyList.removeAll()
        self.pageNumber = 1
        searchString = (textField.text?.trimmingCharacters(in: .whitespaces))!
        self.callAPIToSearchUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .search {
            view.endEditing(true)
        }
        return true
    }
    
    //MARK: - Friend Popup Delegate
    func sendFriendRequest(){
        callAPIToSendFriendRequest()
    }
    
    func cancelFriendRequest(){
        callAPIToCancelFriendRequest()
    }
    
    func rejectFriendrequest() {
        callAPIToAcceptFriendRequest(action: "A")
    }
    
    //MARK:- IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func messageBtnAction(_ sender: UIButton) {
        
        let obj = familyList[sender.tag]
        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        receiverUserInfo = obj
        
        if obj.fRequestStatus == "FRIEND" {
            
            if obj.quickBloxID.count == 0{
                showAlert(title: "Warning", message: "Account is not register with QuickBlox.", controller: self)
            }else{
                APPDELEGATE.createNewDailog(quickBloxId: UInt(obj.quickBloxID)!)
            }
        }else if obj.fRequestStatus == "REQ_SENT"{
            objVC.messageString = "Are you sure want to cancel friend request?"
            objVC.isFromRequestSend = false
            objVC.friendRequestStatus = FriendRequestStatus.IsCancelFriendRequest
            objVC.popupDelegate = self
            objVC.modalPresentationStyle = .overFullScreen
            self.present(objVC, animated: true, completion: nil)
        }else if obj.fRequestStatus == "REQ_RECEIVED"{
            
            objVC.messageString = "Are you sure want to accept \(obj.fUserFirstName) \(obj.fLastName) request?"
            objVC.isFromRequestSend = false
            objVC.popupDelegate = self
            objVC.isFromApproveReject = true
            objVC.modalPresentationStyle = .overFullScreen
            self.present(objVC, animated: true, completion: nil)
        }else{
            objVC.messageString = "Are you sure want to send \(obj.fUserFirstName) a connection request?"
            objVC.isFromRequestSend = false
            objVC.popupDelegate = self
            objVC.modalPresentationStyle = .overFullScreen
            self.present(objVC, animated: true, completion: nil)
        }
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((mytableView.contentOffset.y + mytableView.frame.size.height) >= mytableView.contentSize.height) {
            if pageNumber < totalPage{
                pageNumber += 1
                self.callAPIToSearchUser()
            }
        }
    }
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return familyList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 56
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        let obj = familyList[indexPath.row]
        
        cell.titleLabel.text = "\(obj.fUserFirstName)\(obj.fLastName)"
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        cell.messageBtn.isHidden = false
        cell.messageBtn.tag = indexPath.row
        cell.messageBtn.addTarget(self, action: #selector(self.messageBtnAction(_:)), for: .touchUpInside)
        cell.profileImageView.layer.cornerRadius = 20
        cell.profileImageView.layer.masksToBounds = true
        
        if obj.fRequestStatus == "FRIEND" {
            cell.messageBtn.setImage(#imageLiteral(resourceName: "message"), for: .normal)
        }else if obj.fRequestStatus == "REQ_SENT" {
            cell.messageBtn.setImage(#imageLiteral(resourceName: "unfriend"), for: .normal)
        }
        else if obj.fRequestStatus == "REQ_RECEIVED"{
            cell.messageBtn.setImage(#imageLiteral(resourceName: "friendRequest"), for: .normal)
        }else {
            cell.messageBtn.setImage(#imageLiteral(resourceName: "request_sent_top"), for: .normal)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
        objVC.isFriend = 1
        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
    }
    
    //MARK: - Service Helper Methods
    func callAPIToSearchUser(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["search"] = searchString as AnyObject
        dictParams["page"] = pageNumber as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kSearchFriendsAPI) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.familyList = FriendInfo.getSearchFriendList(list:(responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]), existingList: self.familyList)
                    self.totalPage = responseDict.validatedValue("last_page", expected: 0 as AnyObject) as! Int
                    self.mytableView.reloadData()
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func callAPIToSendFriendRequest(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["receiver_user_id"] = receiverUserInfo.fUserID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kSendFriendRequestAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.pageNumber = 1;
                    self.familyList.removeAll()
                    self.callAPIToSearchUser()
                    
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "We have send \(self.receiverUserInfo.fUserFirstName) \(self.receiverUserInfo.fLastName) a connection request we will notify you as soon as we get a response."
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
    
    func callAPIToCancelFriendRequest(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["friend_user_id"] = receiverUserInfo.fUserID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kCancelFriendRequest) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.pageNumber = 1;
                    self.familyList.removeAll()
                    self.callAPIToSearchUser()

                    
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "We have send \(self.receiverUserInfo.fUserFirstName) \(self.receiverUserInfo.fLastName) a connection request we will notify you as soon as we get a response."
                    objVC.isFromRequestSend = true
                    objVC.titleString = "Success"
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
                    
                    self.pageNumber = 1;
                    self.familyList.removeAll()
                    self.callAPIToSearchUser()

                    
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "Request \(action == "A" ?"accept":"reject") successfully."
                    objVC.isFromRequestSend = true
                    objVC.titleString = "Success"
                    objVC.modalPresentationStyle = .overFullScreen
                    self.present(objVC, animated: true, completion: nil)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
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

