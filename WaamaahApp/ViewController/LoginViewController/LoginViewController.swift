//
//  LoginViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var signInBtn: UIButton!
    
    //variables
    let userInfo = UserInfo()
    var errorIndex = -1
    var errorMessage:String = ""
    
    //MARK: - UIVIewControllerLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialMethods()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethods(){
        
        self.signInBtn.layer.cornerRadius = self.signInBtn.layer.frame.size.height / 2
        self.myTableView.rowHeight = UITableViewAutomaticDimension
        self.myTableView.estimatedRowHeight = 100
        
    }
    
    func isValidateAllField() -> Bool{
        
        if userInfo.emailStr.count == 0 {
            errorMessage = "Please enter email ID."
        }else if userInfo.emailStr.isValidEmail() == false{
            errorMessage = "Please enter valid email ID."
        }else if userInfo.passwordStr.count == 0{
            errorMessage = "Please enter password."
        }else if userInfo.passwordStr.count < 6{
            errorMessage = "Please enter 6 characters password."
        }else {
            errorMessage = ""
            return true
        }
        showAlert(title: "Warning", message: errorMessage, controller: self)
        return false
    }
    
    //MARK: - UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag {
        case 100:
            if string.isEqual("") == true || str.length <= 64 {
                return true
            } else {
                return false
            }
        case 101:
            if string.isEqual("") == true || str.length <= 16 {
                return true
            } else {
                return false
            }
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        if textField.tag == 100{
            //email textfield
            userInfo.emailStr = (textField.text?.removeWhitespace())!
        }else {
            //password textfield
            userInfo.passwordStr = (textField.text?.removeWhitespace())!
        }
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
        }
        return true
    }

    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        for controller in (APPDELEGATE.navigationController.viewControllers){
            if controller.isKind(of: RouteViewController.self){
                APPDELEGATE.navigationController.popToViewController(controller, animated: true)
                return
            }else if controller.isKind(of: SignUpViewController.self){
                APPDELEGATE.navigationController.popToViewController(controller, animated: true)
                return
            }
        }
        
        let loginVC = authStoryboard.instantiateViewController(withIdentifier: "RouteViewController")
        APPDELEGATE.navigationController.pushViewController(loginVC, animated: true)
        
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
       self.view.endEditing(true)
        if isValidateAllField() {
            callAPIToUserLogin()
        }
    }
    
    @objc func forgotBtnAction(sender:UIButton){
        self.view.endEditing(true)
        let objVC = authStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        for controller in (self.navigationController?.viewControllers)!{
            if controller.isKind(of: SignUpViewController.self){
                self.navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
        
        let objVC = authStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    //MARK: - UITableView Delegate & DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 2
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as! TextFieldTableViewCell
        
        cell.inputTextField.delegate = self
        cell.inputTextField.tag = indexPath.row + 100
        cell.inputTextField.autocorrectionType = .no
        cell.inputTextField.placeHolderColor = UIColor.lightGray
        cell.inputTextField.titleTextColour = UIColor.lightGray
        cell.inputTextField.titleActiveTextColour = UIColor.lightGray
        cell.forgotBtnWidthConstant.constant = 0
        cell.inputTextField.bottomLineView.isHidden = true;
        cell.separatorLabel.isHidden = false
        cell.forgotBtn.addTarget(self, action: #selector(self.forgotBtnAction(sender:)), for: .touchUpInside)
        cell.errorLabel.text = ""
        if errorIndex == indexPath.row {
            cell.errorLabel.text = errorMessage
        }
        
        if indexPath.row == 0{
            cell.inputTextField.placeholder = "Email"
            cell.inputTextField.keyboardType = .emailAddress
            cell.inputTextField.returnKeyType = .next
            cell.inputTextField.text = userInfo.emailStr
            cell.inputTextField.isSecureTextEntry = false
        }else{
            cell.inputTextField.placeholder = "Password"
            cell.inputTextField.keyboardType = .default
            cell.inputTextField.returnKeyType = .done
            cell.inputTextField.text = userInfo.passwordStr
            cell.inputTextField.isSecureTextEntry = true
            cell.forgotBtnWidthConstant.constant = 60
        }
        
        return cell
        
    }
    
    //MARK: - Service Helper Methods
    //Call Api to Login
    func callAPIToUserLogin(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kEmail] = userInfo.emailStr as AnyObject
        dictParams[kPassword] = userInfo.passwordStr as AnyObject
        dictParams[kDeviceFcmToken] = UserDefaults.standard.value(forKey: "deviceToken") as AnyObject
        dictParams[kDeviceType] = "I" as AnyObject
        
        showHud()
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: false, params: dictParams , apiName: kLoginAPI) { (response, error) in
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
                    
                    let dict = responseDict.validatedValue(kData, expected:[:] as AnyObject ) as! Dictionary<String, AnyObject>
                    let ids = dict.validatedValue("quickblox_id", expected: "" as AnyObject) as! String
                    
                    if ids.count != 0{
                        self.getUserWithQuickBloxID(quickBloxID: UInt(ids)!)
                    }
                    
                    UserDefaults.standard.set(responseDict.validatedValue(kAccessToken, expected: "" as AnyObject), forKey: kAccessToken)
                    UserDefaults.standard.set((responseDict.validatedValue(kData, expected:[:] as AnyObject ) as! Dictionary<String, AnyObject>).validatedValue(kID, expected: "" as AnyObject), forKey: kUserID)

                    UserDefaults.standard.set((responseDict.validatedValue(kData, expected:[:] as AnyObject ) as! Dictionary<String, AnyObject>).validatedValue(kFirstName, expected: "" as AnyObject), forKey: kFirstName)
                    UserDefaults.standard.set((responseDict.validatedValue(kData, expected:[:] as AnyObject ) as! Dictionary<String, AnyObject>).validatedValue(kLastName, expected: "" as AnyObject), forKey: kLastName)
                    UserDefaults.standard.set((responseDict.validatedValue(kData, expected:[:] as AnyObject ) as! Dictionary<String, AnyObject>).validatedValue(kEmail, expected: "" as AnyObject), forKey: kEmail)

                    let isEditStatus = dict.validatedValue("is_profile_updated", expected: "" as AnyObject) as! String
                    APPDELEGATE.callAPIToSendLocation()
                    if isEditStatus == "1"{
                        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                        self.navigationController?.pushViewController(objVC, animated: true)
                        UserDefaults.standard.set(false, forKey: "isEdit")
                    }else{
                        let objVC = settingStoryboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                        objVC.isFromLogin = true
                        self.navigationController?.pushViewController(objVC, animated: true)
                        UserDefaults.standard.set(true, forKey: "isEdit")
                    }
                    UserDefaults.standard.synchronize()
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func getUserWithQuickBloxID(quickBloxID: UInt){
        showHud()
        QBRequest.user(withID: quickBloxID, successBlock: { (response, user) in
            
            if response.status.rawValue == 200{
                
                self.logInChatWithUser(user: user)
            }
            
        }) { (error) in
             hideHud()
            showAlert(title: "Error", message: "User not fetch from Quickblox.", controller: self)
        }
        
    }
    
    func logInChatWithUser(user: QBUUser) {
        let password = "\(UserDefaults.standard.value(forKey: kUserID) ?? "")WXYZ1234"
        user.password = password.toBase64()
        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logIn(with: user, completion:{
             (success, errorMessage) -> Void in
            hideHud()
            guard success else {
                logInfo(message:"connect")
                return
            }
            APPDELEGATE.sbscriptionSetup()
            //showAlert(title: "Error", message: "User do not login with Quickblox.", controller: self)
        })
        
        
    }
    
    //MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
