//
//  ChangePasswordViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 26/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    //outlet
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var changePasswordTableView: UITableView!
    
    //outlet
    let userInfo = UserInfo()
    var isFromOTP: Bool = false
    var emailStr : String = ""
    var securityCode : String = ""
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethods(){
        
        topView.setShadow(radius: 0)
       
        if isFromOTP{
            titleLabel.text = "RESET PASSWORD"
        }else{
            titleLabel.text = "CHANGE PASSWORD"
        }
    }

    func isValidateAllField() -> Bool{
        self.view.endEditing(true)
        
        if !isFromOTP{
            if userInfo.passwordStr.count == 0 {
                showAlert(title: "Warning", message: "Please enter current password.", controller: self)
                return false
            }
        }
        
        var errorMessage = ""
        if userInfo.newPasswordStr.count == 0{
            errorMessage = "Please enter new password."
        }else if userInfo.newPasswordStr.count < 6{
            errorMessage = "Please enter minimum 6 characters new password."
        }else if userInfo.confirmPassword.count == 0{
            errorMessage = "Please enter confirm new password."
        }else if userInfo.newPasswordStr != userInfo.confirmPassword{
            errorMessage = "New password and confirm new password must be same."
        }else {
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
        if string.isEqual("") == true || str.length <= 64 {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isFromOTP {
            if textField.tag == 100{
                //password textfield
                userInfo.newPasswordStr = (textField.text?.removeWhitespace())!
            }else{
                userInfo.confirmPassword = (textField.text?.removeWhitespace())!
            }
            return
        }
        
        if textField.tag == 100{
            //email textfield
            userInfo.passwordStr = (textField.text?.removeWhitespace())!
        }else if textField.tag == 101{
            //password textfield
            userInfo.newPasswordStr = (textField.text?.removeWhitespace())!
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
    
    //MARK: - IBAction Methods
    @IBAction func updatePasswordBtnAction(_ sender: Any) {
        
        if isValidateAllField() {
            
            if isFromOTP{
                callAPIToResetPassword()
            }else{
                callAPIToChangePassword()
            }
        }
        
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView Delegate and DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if isFromOTP {
            return 2
        }
        return 3
    }
   
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as! TextFieldTableViewCell
       
        cell.inputTextField.delegate = self
        cell.inputTextField.tag = indexPath.row + 100
        cell.inputTextField.autocorrectionType = .no
        cell.inputTextField.placeHolderColor = UIColor.lightGray
        cell.inputTextField.titleTextColour = UIColor.lightGray
        cell.inputTextField.titleActiveTextColour = UIColor.lightGray
        cell.forgotBtnWidthConstant.constant = 0
        cell.inputTextField.bottomLineView.isHidden = true;
        cell.separatorLabel.isHidden = false
        cell.inputTextField.returnKeyType = .next
        cell.inputTextField.isSecureTextEntry = true
        
        if isFromOTP {
            if indexPath.row == 0{
                cell.inputTextField.placeholder = "New Password"
                cell.inputTextField.text = userInfo.newPasswordStr
            }else{
                cell.inputTextField.returnKeyType = .done
                cell.inputTextField.placeholder = "Confirm New Password"
                cell.inputTextField.text = userInfo.confirmPassword
            }
        }else{
            if indexPath.row == 0{
                cell.inputTextField.placeholder = "Current Password"
                cell.inputTextField.text = userInfo.passwordStr
            }else if indexPath.row == 1{
                cell.inputTextField.placeholder = "New Password"
                cell.inputTextField.text = userInfo.newPasswordStr
            }else{
                cell.inputTextField.returnKeyType = .done
                cell.inputTextField.placeholder = "Confirm New Password"
                cell.inputTextField.text = userInfo.confirmPassword
            }
        }
        
        return cell
    }
    
    //MARK:- Service Helper Methods
    //Call Api Change Password
    func callAPIToChangePassword(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["current_password"] = userInfo.passwordStr as AnyObject
        dictParams["new_password"] = userInfo.newPasswordStr as AnyObject

        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kChangePasswordAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                    self.userInfo.passwordStr = ""
                    self.userInfo.newPasswordStr = ""
                    self.userInfo.confirmPassword = ""
                    self.changePasswordTableView.reloadData()
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
        
    }
    
    func callAPIToResetPassword(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams["email"] = emailStr as AnyObject
        dictParams["security_code"] = securityCode as AnyObject
        dictParams["password"] = userInfo.newPasswordStr as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kResetPassword) { (response, error) in
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
                        
                        for controller in (self.navigationController?.viewControllers)!{
                            if controller.isKind(of: LoginViewController.self){
                                self.navigationController?.popToViewController(controller, animated: true)
                                return
                            }
                        }
                        self.navigationController?.popToRootViewController(animated: true)
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
    
    //MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
