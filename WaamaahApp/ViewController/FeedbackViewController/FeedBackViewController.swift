//
//  FeedBackViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 17/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import SDWebImage

class FeedBackViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, FilterPopupProtocal, RequestPopupProtocol, UITextFieldDelegate {

    //MARK: - Outlet and instance Variables
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var dayCollectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewRightConstant: NSLayoutConstraint!
    @IBOutlet weak var searchViewLeftConstant: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    
    //instance variable
    var dayList = [Dictionary<String,AnyObject>]()
    var userList = [FriendInfo]()
    var selectedIndex = 0
    var selectedFilter = [String]()
    var selectedDate: Date = Date()
    var receiverUserInfo = FriendInfo()
    var pageNumber:Int = 1
    var totalPage : Int = 0;
    var filterName: String = ""
    
    //MARK:- UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethods()
        self.getPreviousDateList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pageNumber = 1
        userList.removeAll()
        callAPIToGetCapturedUsers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Helper Methods
    func initialMethods(){
        
        self.topView.setShadow(radius: 0)
        self.searchView.layer.cornerRadius = 6
        searchViewLeftConstant.constant = -(WINDOW_WIDTH + searchViewLeftConstant.constant)
        searchViewRightConstant.constant = (WINDOW_WIDTH + searchViewRightConstant.constant)
        self.searchTextField.delegate = self
       
    }
    
    func getPreviousDateList(){
        
        dayList.append(["title":"Today" as AnyObject,"date":Date() as AnyObject])
        var date = Date().yesterday
        dayList.append(["title":"Yesterday" as AnyObject,"date":date as AnyObject])
        
        for _ in 2 ... 60{
            date = date.yesterday
            
            dayList.append(["title":"\(date.getDayNameWithDate()) \(date.getFormattedMonthStringToDate().addDayExtensionInDate())" as AnyObject,"date":date as AnyObject])
        }
        self.dayCollectionView.reloadData()
    }
    
    //MARK: - UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        filterName = (textField.text?.trimmingCharacters(in: .whitespaces))!
        self.userList.removeAll()
        self.callAPIToGetCapturedUsers()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .search {
            view.endEditing(true)
        }
        return true
    }
    
    //MARK:- Selector Methods
    @objc func messageBtnAction(sender: UIButton){
        
        let obj = userList[sender.tag]
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
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            searchViewLeftConstant.constant = 8
            searchViewRightConstant.constant = 8
        }else{
            searchViewLeftConstant.constant = -(WINDOW_WIDTH + searchViewLeftConstant.constant)
            searchViewRightConstant.constant = (WINDOW_WIDTH + searchViewRightConstant.constant)
            filterName = ""
            self.userList.removeAll()
            self.callAPIToGetCapturedUsers()
        }
        
        
        UIView.animate(withDuration: 0.30,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
        
    }
    
    @IBAction func filetrBtnAction(_ sender: Any) {
        
        let filterPopup = profileStoryboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        filterPopup.delegate = self
        filterPopup.selectedContent = selectedFilter
        filterPopup.modalPresentationStyle = .overFullScreen
        self.present(filterPopup, animated: true, completion: nil)
        
        
    }
    
    //MARK: - FilterPopup Delegate Methods
    func dissmissFilterPopup(selectedIDs:[String]){
        logInfo(message: "Selcted option - \(selectedIDs)")
        selectedFilter = selectedIDs
        pageNumber = 1;
        self.userList.removeAll()
        callAPIToGetCapturedUsers()
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
    
    //MARK:- UICollectionView Delegate & DataSource methods
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dayList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
      
        let font : UIFont = UIFont.init(name: "Poppins-Regular", size: 15.0)!
        let text = dayList[indexPath.row]["title"]
        let width = UILabel.textWidth(font: font, text: text as! String)
        return CGSize(width: width + 20, height: 40)
        
    }
  
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCollectionViewCell", for: indexPath) as! LabelCollectionViewCell
        cell.titleLabel.text = dayList[indexPath.item]["title"] as? String
        if selectedIndex == indexPath.row{
            cell.containerView.backgroundColor = APPORANGECOLOR
            cell.containerView.layer.shadowColor = UIColor.darkGray.cgColor
            cell.containerView.layer.shadowOffset = CGSize(width: 1,height: 2)
            cell.containerView.layer.shadowRadius = 2.0
            cell.containerView.layer.shadowOpacity = 0.5
            cell.containerView.layer.masksToBounds = false
            cell.titleLabel.textColor = UIColor.white
        }else{
            cell.containerView.backgroundColor = UIColor.white
            cell.containerView.layer.shadowColor = UIColor.clear.cgColor
            cell.titleLabel.textColor = UIColor.black
        }
        cell.containerView.layer.cornerRadius = cell.containerView.frame.size.height / 2
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        selectedIndex = indexPath.item
        selectedDate = dayList[indexPath.item]["date"] as! Date
        self.dayCollectionView.reloadData()
        pageNumber = 1;
        self.userList.removeAll()
        callAPIToGetCapturedUsers()
    }
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return userList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 101
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        
        let obj = userList[indexPath.item]
        
        cell.titleLabel.text = "\(obj.fUserFirstName) \(obj.fLastName)"
        cell.dayTimeLabel.text = "\(obj.fUpdateAt.getTimeStringToDate()) \(obj.fAddress)"
        cell.messageBtn.tag = indexPath.row
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        
        cell.messageBtn.addTarget(self, action: #selector(self.messageBtnAction(sender:)), for: .touchUpInside)
        if obj.fRequestStatus == "FRIEND" {
            cell.messageBtn.setImage(#imageLiteral(resourceName: "message"), for: .normal)
        }else if obj.fRequestStatus == "REQ_SENT"{
            cell.messageBtn.setImage(#imageLiteral(resourceName: "unfriend"), for: .normal)
        }else if obj.fRequestStatus == "REQ_RECEIVED"{
            cell.messageBtn.setImage(#imageLiteral(resourceName: "friendRequest"), for: .normal)
        }else{
            cell.messageBtn.setImage(#imageLiteral(resourceName: "request_send"), for: .normal)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let obj = userList[indexPath.item]
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
        objVC.profileUserID = obj.fUserID
        
        if obj.fRequestStatus == "FRIEND" {
            objVC.isFriend = 1
            objVC.friendRquestStstus = FriendRequestStatus.Friend
        }else{
            objVC.friendRquestStstus = FriendRequestStatus.Unfriend
            objVC.isFriend = 0
        }
        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
        
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((myTableView.contentOffset.y + myTableView.frame.size.height) >= myTableView.contentSize.height) {
            if pageNumber < totalPage{
                pageNumber += 1
                self.callAPIToGetCapturedUsers()
            }
        }
    }
    
    //MARK:- Service Helper Methods
    func callAPIToGetCapturedUsers(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["date"] = selectedDate.getDateString() as AnyObject
        dictParams["filters"] = selectedFilter as AnyObject
        dictParams["search"] = filterName as AnyObject
        dictParams["page"] = pageNumber as AnyObject
        
        hideHud()
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kGetCapturedUserAPI) { (response, error) in
            hideHud()

            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.userList = FriendInfo.getCloseFriendList(list: (responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]),friendList: self.userList)
                    
                    if self.userList.count > 0{
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
    
    func callAPIToSendFriendRequest(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["receiver_user_id"] = receiverUserInfo.fCapturedUserID as AnyObject
        
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
                    self.userList.removeAll()
                    self.callAPIToGetCapturedUsers()
                    
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
        dictParams["friend_user_id"] = receiverUserInfo.fCapturedUserID as AnyObject
        
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
                    self.userList.removeAll()
                    self.callAPIToGetCapturedUsers()
                    
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
                    self.userList.removeAll()
                    self.callAPIToGetCapturedUsers()
                    
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



