//
//  AddFamilyMemberViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 24/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class AddFamilyMemberViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlet and Instance Variables
    @IBOutlet weak var mytableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var transparentView: UIView!
    var familyList = [FriendInfo]()
    var pageNumber: Int = 1
    var totalPage: Int = 1
    var relationList = [Dictionary<String, AnyObject>]()
    var textField: UITextField?
    
    //MARK:- UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialMethods()
        self.callAPIToGetFamilyMemberList()
        callAPIToGetRelationList()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Helper Methods
    func initialMethods(){
        
        topView.setShadow(radius: 0)
        
    }
    
    func openRelationList(selectdID: String){
        
        var tempList = [String]()
        
        for dict in self.relationList{
            tempList.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
        }
        
        DPPickerManager.shared.showPicker(title: "Select Relation", selected: "", strings: tempList) { (selected, index, cancel) in
            
            if !cancel {
                let id = (self.relationList[index]).validatedValue("id", expected: "" as AnyObject)

                if selected == "Other"{
                    
                    let alert = UIAlertController(title: "", message: "Enter Relation", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addTextField(configurationHandler: self.configurationTextField)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction) in
                      
                        self.callAPIToAddFriendInFamilyMember(friendUserID: selectdID, relationID: id as! String, otherDetails: (self.textField?.text)!)

                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    self.callAPIToAddFriendInFamilyMember(friendUserID: selectdID, relationID: id as! String, otherDetails: "")
                }
            }
        }
        
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "Some text";
        }
    }
    
    //MARK:- IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return familyList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 70
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        let obj = familyList[indexPath.row]
        
        cell.titleLabel.text = "\(obj.fUserFirstName)\(obj.fLastName)"
        cell.dayTimeLabel.text = ""
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        
        cell.messageBtn.isHidden = true
        cell.profileImageView.layer.cornerRadius = 20
        cell.profileImageView.layer.masksToBounds = true
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let obj = familyList[indexPath.row]
        self.openRelationList(selectdID: obj.anotherUserID)
        
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((mytableView.contentOffset.y + mytableView.frame.size.height) >= mytableView.contentSize.height) {
            if pageNumber < totalPage{
                pageNumber += 1
                self.callAPIToGetFamilyMemberList()
            }
        }
    }
    
    //MARK: - Service Helper Methods
    func callAPIToGetFamilyMemberList(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["page"] = pageNumber as AnyObject
     
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kGetUnFamilyMemberAPI) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.familyList = FriendInfo.getUnFamilyMemberlist(list: (responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]), familyList: self.familyList)
                    self.totalPage = responseDict.validatedValue("last_page", expected: 0 as AnyObject) as! 
                    Int
                    
                    if self.familyList.count == 0{
                        self.transparentView.isHidden = false
                    }else{
                        self.transparentView.isHidden = true
                    }
                    
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
    
    func callAPIToGetRelationList(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: false, params: dictParams , apiName: kGetRelationList) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.relationList = responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
                    
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
    
    func callAPIToAddFriendInFamilyMember(friendUserID:String, relationID:String, otherDetails:String){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["another_user_id"] = friendUserID as AnyObject
        dictParams["family_relation_id"] = relationID as AnyObject
        dictParams["other_relation_detail"] = otherDetails as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kAddFriendInFamilyMember) {  (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                   
                    showAlert(title:"Success" , message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self, acceptBlock: {
                        
                        for controller in (self.navigationController?.viewControllers)!{
                            if controller.isKind(of: EditProfileViewController.self){
                                self.navigationController?.popToViewController(controller, animated: true)
                                return
                            }
                        }
                        
                    })
                    
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
