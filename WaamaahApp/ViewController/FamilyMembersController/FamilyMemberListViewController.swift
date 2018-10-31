//
//  FamilyMemberListViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 24/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class FamilyMemberListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlet and Instance Variables
    @IBOutlet weak var mytableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    var familyList = [FriendInfo]()
    var pageNumber: Int = 1
    var totalPage: Int = 1

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
        self.callAPIToGetFamilyMemberList()
    }
    
    //MARK:- Helper Methods
    func initialMethods(){
        
        topView.setShadow(radius: 0)
        
    }
    
    //MARK:- IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func plusBtnAction(_ sender: Any) {
        
        let objvc = profileStoryboard.instantiateViewController(withIdentifier: "AddFamilyMemberViewController") as! AddFamilyMemberViewController
        self.navigationController?.pushViewController(objvc, animated: true)
        
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
        cell.dayTimeLabel.text = "Relation: \(obj.relationStr)"
        cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options:.continueInBackground, completed: nil)
        
        cell.messageBtn.isHidden = true
        cell.profileImageView.layer.cornerRadius = 20
        cell.profileImageView.layer.masksToBounds = true
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
//        objVC.isFriend = 1
//        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
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
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["page"] = pageNumber as AnyObject
        
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
                    
                    self.familyList = FriendInfo.getFamilyMemberlist(list: (responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]), familyList: self.familyList)
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
    
    //MARK:- Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
