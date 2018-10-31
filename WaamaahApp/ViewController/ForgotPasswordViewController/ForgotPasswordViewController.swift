//
//  ForgotPasswordViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 16/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    let userInfo = UserInfo()
    @IBOutlet weak var forgotBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialMethods()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK - Helper Methods
    func initialMethods(){
        
        self.forgotBtn.layer.cornerRadius = self.forgotBtn.layer.frame.size.height / 2
        
    }
    
    func isValidateAllField() -> Bool{
        var message = ""
        if userInfo.emailStr.count == 0 {
            message = "Please enter email ID."
        }else if userInfo.emailStr.isValidEmail() == false{
            message = "Please enter valid email ID."
        }else {
            message = ""
            return true
        }
        
        showAlert(title: "Warning", message: message, controller: self)
        
        return false
    }
    
    //MARK - UITextField Delegate Methods
    //MARK: - UITextField Delegate Methods.
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
         userInfo.emailStr = (textField.text?.removeWhitespace())!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
       view.endEditing(true)
        return true
    }
    
    //MARK: - UIButton Action Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        if isValidateAllField() {
            self.callAPIToGetPassword()
        }
        
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK - UITableView Delegate & DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
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
        
        cell.inputTextField.placeholder = "Email"
        cell.inputTextField.keyboardType = .emailAddress
        cell.inputTextField.returnKeyType = .next
        cell.inputTextField.text = userInfo.emailStr
        cell.inputTextField.tag =   102
        cell.inputTextField.isSecureTextEntry = false
        
        return cell
    }
    
    //MARK: - Service Helper Methods
    func callAPIToGetPassword(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams["email"] = userInfo.emailStr as AnyObject
        
        //create_user
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kForgotPasswordAPI) { (response, error) in
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
                        let objVC = authStoryboard.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                        objVC.emailStr = self.userInfo.emailStr
                        self.navigationController?.pushViewController(objVC, animated: true)
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
    
    //MARK - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
