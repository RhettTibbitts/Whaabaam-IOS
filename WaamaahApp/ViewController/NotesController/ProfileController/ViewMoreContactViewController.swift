//
//  ViewMoreContactViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 17/09/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ViewMoreContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //MARK:- IBOutlet and instance objects
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    
    //instance vairiable
    var titleString:String = ""
    var profileUserID:String = ""
    var contactList = [FriendInfo]()
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
        
        if titleString == "Mutual Contact" {
            self.callAPIToFetchMutualContact()
        }else{
            self.callAPIToFetchMutualFamily()
        }
    }
    
    //MARK:- Initial Methods
    func initialSetup(){
        self.topView.setShadow(radius: 0)
        self.titleLabel.text = titleString
        
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return contactList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        let obj = contactList[indexPath.row]
        
        cell.titleLabel.text = "\(obj.fUserFirstName)\(obj.fLastName)"
        cell.dayTimeLabel.text = ""
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        cell.dayTimeLabel.text = obj.relationStr
        cell.messageBtn.isHidden = true
        cell.profileImageView.layer.cornerRadius = 18
        cell.profileImageView.layer.masksToBounds = true
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
       // let obj = contactList[indexPath.row]
      //  self.openRelationList(selectdID: obj.anotherUserID)
        
    }
    
    //MARK: - Service Helper Methods
    func callAPIToFetchMutualContact(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["profile_user_id"] = profileUserID as AnyObject

        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kMutualFriendListAPI) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.contactList = FriendInfo .getMutualContactlist(list: responseDict.validatedValue(kData, expected: [] as AnyObject ) as! [Dictionary<String, AnyObject>], familyList: self.contactList);
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
    
    func callAPIToFetchMutualFamily(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  self.profileUserID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kGetFamilyMemberListAPI) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.contactList = FriendInfo .getMutualFamilylist(list: responseDict.validatedValue(kData, expected: [] as AnyObject ) as! [Dictionary<String, AnyObject>], familyList: self.contactList);
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
