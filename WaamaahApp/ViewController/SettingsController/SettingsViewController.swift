//
//  SettingsViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 24/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QMChatServiceDelegate, QMChatConnectionDelegate, QMAuthServiceDelegate, MFMailComposeViewControllerDelegate {

    //outlet
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    //instance varibale
    var settingList = [Dictionary<String, Any>]()
    var isFriend:Int = 0
    private var observer: NSObjectProtocol?
    
    //MARK:- UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethod()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethod(){
        
        settingList = [["image":"setting_notification","name":"Notification Preferences"],["image":"my_profile","name":"My Profile"],["image":"change_password","name":"Change Password"],["image":"my_connactions-1","name":"My Connections"], ["image":"email","name":"Contact Us"]]
        
        self.topView.setShadow(radius: 4)
        
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            if !QBChat.instance.isConnected {
            }
        }
    }
    
    func launchEmail() {
        
        let emailTitle = "Support Request"
        
        let messageBody = "\n\n\n\nApp Version:  \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)\nOS version: \(UIDevice.current.systemVersion)\nUserID: \(UserDefaults.standard.value(forKey: kUserID) as! String)\n Username: \(UserDefaults.standard.value(forKey: kFirstName) as! String) \(UserDefaults.standard.value(forKey: kLastName) as! String)\nEmail ID: \(UserDefaults.standard.value(forKey: kEmail)as! String)"
        
        let toRecipents = ["admin@whaabaam.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        self.present(mc, animated: true, completion: nil)
    }
    
    //MARK: - Mail Composer Delegate Method
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        self.dismiss(animated: true, completion: nil)
        switch result {
        case .cancelled:
            showAlert(title: "Warning", message: "Email cancelled.", controller: self)
            break
        case .saved:
            showAlert(title: "Success", message: "Email save in draft.", controller: self)
            break
        case .sent:
            showAlert(title: "Success", message: "Email send successfully.", controller: self)
            break
        case .failed:
            showAlert(title: "Error", message: "Email send failed.", controller: self)
            break
        }
        
    }

    //MARK: - IBActionMethods
    @IBAction func logoutBtnAction(_ sender: Any) {
        callAPIToLogoutUser()
    }
    
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return settingList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 64
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : SettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        var dict: Dictionary<String, Any> = settingList[indexPath.row]

        cell.titleImage.image = UIImage.init(named: dict["image"] as! String)
        cell.titleLabel.text = dict["name"] as? String
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        switch indexPath.row {
        case 0:
            let objVC = settingStoryboard.instantiateViewController(withIdentifier: "NotificationKeywordViewController") as! NotificationKeywordViewController
            objVC.isFromSetting = true
            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
            break
        case 1:
            let objVC = settingStoryboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
            //objVC.isFromSetting = true
            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
            break
        case 2:
            let objVC = settingStoryboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
            break
        case 3:
            let objVC = mainStoryboard.instantiateViewController(withIdentifier: "ConnectionViewController") as! ConnectionViewController
            APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
            break
        case 4:
           self.launchEmail()
            break
        default:
            break
        }
    }
    
    //MARK: - Service Helper Methods
    //Call Api to Logout
    func callAPIToLogoutUser(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kLogoutAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self, acceptBlock: {
                        UserDefaults.standard.set("", forKey: kAccessToken)
                        UserDefaults.standard.synchronize()
                        self.logoutFromQuickBlox()
                        for controller in (APPDELEGATE.navigationController.viewControllers){
                            if controller.isKind(of: LoginViewController.self){
                                APPDELEGATE.navigationController.popToViewController(controller, animated: true)
                                return
                            }
                        }
                        let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                        APPDELEGATE.navigationController.pushViewController(loginVC, animated: true)
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
    
    func logoutFromQuickBlox() {
        
        if !QBChat.instance.isConnected {
            
            return
        }
        
        ServicesManager.instance().lastActivityDate = nil
        ServicesManager.instance().logoutUserWithCompletion { [weak self] (boolValue) -> () in
            
            guard let strongSelf = self else { return }
            if boolValue {
                
                NotificationCenter.default.removeObserver(strongSelf)
                
                if strongSelf.observer != nil {
                    NotificationCenter.default.removeObserver(strongSelf.observer!)
                    strongSelf.observer = nil
                }
                
                ServicesManager.instance().chatService.removeDelegate(strongSelf)
                ServicesManager.instance().authService.remove(strongSelf)
                ServicesManager.instance().lastActivityDate = nil;
            }
        }
    }
    
    //MARK:- Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
