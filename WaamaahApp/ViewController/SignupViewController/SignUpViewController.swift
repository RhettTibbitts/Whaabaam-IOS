//
//  SignUpViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var webContainerView: UIView!
    
    @IBOutlet weak var checkboxBtn: UIButton!
    var userInfo = UserInfo()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userInfo = UserInfo()
        myTableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK - Helper Methods
    func initialMethods(){
        
        self.signUpBtn.layer.cornerRadius = self.signUpBtn.layer.frame.size.height / 2
        let urlRequest = URLRequest(url: URL.init(string: "http://whaabaam.com/terms-conditions/")!)
        self.myWebView?.loadRequest(urlRequest)
    }
    
    func isValidateAllField() -> Bool{
        var message = ""
        if userInfo.firstNameStr.count == 0 {
            message = "Please enter first name."
        }else if userInfo.firstNameStr.isValidName() == false{
            message = "Please enter valid first name."
        }else if userInfo.lastNameStr.count == 0{
            message = "Please enter second name."
        }else if userInfo.lastNameStr.isValidName() == false{
            message = "Please enter valid second name."
        }else if userInfo.emailStr.count == 0 {
            message = "Please enter email ID."
        }else if userInfo.emailStr.isValidEmail() == false{
            message = "Please enter valid email ID."
        }else if userInfo.passwordStr.count == 0{
            message = "Please enter password."
        }else if userInfo.passwordStr.count < 6{
            message = "Please enter 6 characters password."
        }else if userInfo.confirmPassword.count == 0{
            message = "Please enter confirm password."
        }else if userInfo.passwordStr != userInfo.confirmPassword{
            message = "Password and confirm password must be same."
        }else if checkboxBtn.isSelected == false{
            message = "Please select terms and condition."
        }else {
            message = ""
            return true
        }
        showAlert(title: "Warning", message: message, controller: self)
        return false
    }
    
    //MARK: - UITextField Delegate Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag {
        case 100, 101, 102:
            if string.isEqual("") == true || str.length <= 64 {
                return true
            } else {
                return false
            }
        case 103,104:
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
            userInfo.firstNameStr = (textField.text?.removeWhitespace())!
        }else if textField.tag == 101 {
            //password textfield
            userInfo.lastNameStr = (textField.text?.removeWhitespace())!
        }else if textField.tag == 102 {
            //password textfield
            userInfo.emailStr = (textField.text?.removeWhitespace())!
        }else if textField.tag == 103 {
            //password textfield
            userInfo.passwordStr = (textField.text?.removeWhitespace())!
        }else{
            userInfo.confirmPassword = (textField.text?.removeWhitespace())!
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        if isValidateAllField() {
           
            callAPIToRegisterUser()
        }
        
    }
    @IBAction func checkBoxBtnAction(_ sender: Any) {
        self.checkboxBtn.isSelected = !checkboxBtn.isSelected
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        for controller in (self.navigationController?.viewControllers)!{
            if controller.isKind(of: LoginViewController.self){
                self.navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
        
        let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    
    @IBAction func openTermsConditionBtn(_ sender: Any) {
       
        self.webContainerView.isHidden = false
    }
    
    @IBAction func closeWebViewBtnAction(_ sender: Any) {
        self.webContainerView.isHidden = true
    }
    
    //MARK: - UITableView Delegate & DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 5
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 68.0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        let cell : TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as! TextFieldTableViewCell
       
        cell.inputTextField.delegate = self
        cell.inputTextField.autocorrectionType = .no
        cell.inputTextField.placeHolderColor = UIColor.lightGray
        cell.inputTextField.titleTextColour = UIColor.lightGray
        cell.inputTextField.titleActiveTextColour = UIColor.lightGray
       // cell.forgotBtnWidthConstant.constant = 0
        cell.inputTextField.bottomLineView.isHidden = true;
        cell.separatorLabel.isHidden = false
        cell.inputTextField.returnKeyType = .next
        cell.inputTextField.autocapitalizationType = .none
        cell.inputTextField.isSecureTextEntry = false
        cell.inputTextField.tag =  indexPath.row + 100
        
        if indexPath.row == 0{
            cell.inputTextField.placeholder = "First Name"
            cell.inputTextField.keyboardType = .emailAddress
            cell.inputTextField.text = userInfo.firstNameStr
            cell.inputTextField.autocapitalizationType = .sentences
        }else if indexPath.row == 1{
            cell.inputTextField.placeholder = "Last Name"
            cell.inputTextField.keyboardType = .emailAddress
            cell.inputTextField.text = userInfo.lastNameStr
            cell.inputTextField.autocapitalizationType = .sentences
        }else if indexPath.row == 2{
            cell.inputTextField.placeholder = "Email"
            cell.inputTextField.keyboardType = .emailAddress
            cell.inputTextField.text = userInfo.emailStr
        }else if indexPath.row == 3{
            cell.inputTextField.placeholder = "Password"
            cell.inputTextField.keyboardType = .default
            cell.inputTextField.text = userInfo.passwordStr
            cell.inputTextField.isSecureTextEntry = true
        }else{
            cell.inputTextField.placeholder = "Confirm Password"
            cell.inputTextField.keyboardType = .default
            cell.inputTextField.returnKeyType = .done
            cell.inputTextField.text = userInfo.confirmPassword
            cell.inputTextField.isSecureTextEntry = true
        }
        
        return cell
    }
    
    //MARK: - Service Helper Methods
    //Call Api to Signup
    func callAPIToRegisterUser(){

        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kFirstName] = userInfo.firstNameStr as AnyObject
        dictParams[kLastName] = userInfo.lastNameStr as AnyObject
        dictParams[kEmail] = userInfo.emailStr as AnyObject
        dictParams[kPassword] = userInfo.passwordStr as AnyObject
        dictParams[kDeviceFcmToken] = UserDefaults.standard.value(forKey: "deviceToken") as AnyObject
        dictParams[kDeviceType] = "I" as AnyObject
        //create_user
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kRegisterAPI) { (response, error) in
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
