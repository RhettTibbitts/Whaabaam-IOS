//
//  ConnectionViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 17/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import SDWebImage

class ConnectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
   
    //Outlet
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewRightConstant: NSLayoutConstraint!
    @IBOutlet weak var searchViewLeftConstant: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    //instance variable
    var userList = [FriendInfo]()
    var pageNumber: Int = 1
    var totalPage: Int = 1
    var filterName: String = ""
    
    //MARK:- UIViewLifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pageNumber = 1
        userList.removeAll()
        self.callAPIToGetFriendList()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Helper Methods
    func initialMethods(){
        //userList = ["Anna Williams", "Bella Abzug", "Charlotte E.","Amelia","Dorothea","fannie Lou"];
        self.topView.setShadow(radius: 0)
        self.searchView.layer.cornerRadius = 6
//        searchViewLeftConstant.constant = -(WINDOW_WIDTH + searchViewLeftConstant.constant)
//        searchViewRightConstant.constant = (WINDOW_WIDTH + searchViewRightConstant.constant)
        self.searchTextField.delegate = self
        
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
        self.callAPIToGetFriendList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        if textField.returnKeyType == .search {
            view.endEditing(true)
        }
        return true
    }
    
    //MARK: - IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchBtAction(_ sender: Any) {
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "SearchCloseFrinedsViewController") as! SearchCloseFrinedsViewController
        self.navigationController?.pushViewController(objVC, animated: true)
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
            self.callAPIToGetFriendList()
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
    
    //MARK:- Selector Methods
    @objc func messageBtnAction(sender: UIButton){
        
        let obj = self.userList[sender.tag]
        
        if obj.quickBloxID.count == 0{
            showAlert(title: "Warning", message: "Account is not register with QuickBlox", controller: self)
        }else{
            APPDELEGATE.createNewDailog(quickBloxId: UInt(obj.quickBloxID)!)
        }

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
        let obj = userList[indexPath.row]
        cell.messageBtn.tag = indexPath.row
        cell.titleLabel.text = "\(obj.fUserFirstName)\(obj.fLastName)"
        cell.dayTimeLabel.text = "\(obj.fUpdateAt.getTimeStringToDate()) \(obj.fAddress)"
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        cell.messageBtn.addTarget(self, action: #selector(self.messageBtnAction(sender:)), for: .touchUpInside)
        
        cell.messageBtn.setImage(#imageLiteral(resourceName: "message"), for: .normal)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let obj = self.userList[indexPath.row]
        
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
        objVC.profileUserID = obj.fUserID
        objVC.isFriend = 1;
        objVC.friendRquestStstus = FriendRequestStatus.Friend
        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
        
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((myTableView.contentOffset.y + myTableView.frame.size.height) >= myTableView.contentSize.height) {
            if pageNumber < totalPage{
                pageNumber += 1
                self.callAPIToGetFriendList()
            }
        }
    }

    //MARK: - Service Helper Methods
    func callAPIToGetFriendList(){

        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["filter_name"] = filterName as AnyObject
        dictParams["page"] = pageNumber as AnyObject

        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kGetFriendListAPI) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }

            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {

                    self.userList = FriendInfo.getConnectionFriendList(list: (responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]), friendList: self.userList)
                    
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
    
    //MARK:- Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
