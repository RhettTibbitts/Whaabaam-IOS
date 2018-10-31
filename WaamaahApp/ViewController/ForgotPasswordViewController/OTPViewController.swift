//
//  OTPViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 06/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class OTPViewController: UIViewController, VPMOTPViewDelegate {
    
    //outlet
    @IBOutlet weak var otpView: VPMOTPView!
    
    //instance variable
    var enteredOtp: String = ""
    var isFillOTP : Bool = false
    var emailStr : String = ""
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    //MARK: - Helper Methods
    func initialSetup(){
        otpView.otpFieldsCount = 6
        otpView.otpFieldDefaultBorderColor = UIColor.lightGray
        otpView.otpFieldEnteredBorderColor = APPORANGECOLOR
        otpView.otpFieldErrorBorderColor = APPORANGECOLOR
        otpView.otpFieldBorderWidth = 2
        otpView.delegate = self
        otpView.shouldAllowIntermediateEditing = false
        
        // Create the UI
        otpView.initializeUI()
    }
    
    //MARK: - IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        if !isFillOTP {
            showAlert(title: "Warning", message: "Please enter 6 digits OTP.", controller: self)
        }else{
            callAPIToSendOTP()
        }
    }
    
    @IBAction func resendBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        self.callAPIToResendOTP()
    }
    
    //MARK: - Custom OTP View Delegate Methods
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        logInfo(message:"Has entered all OTP? \(hasEntered)")
        isFillOTP = hasEntered
        return enteredOtp == enteredOtp
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otpString: String) {
        enteredOtp = otpString
        logInfo(message:"OTPString: \(otpString)")
    }
    
    //MARK: - Service Helper Methods
    func callAPIToSendOTP(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams["email"] = emailStr as AnyObject
        dictParams["verify_code"] = enteredOtp as AnyObject
        
        //create_user
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kVerifyOTPAPI) { (response, error) in
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
                        let objVC = settingStoryboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
                        objVC.emailStr = self.emailStr
                        objVC.isFromOTP = true
                        objVC.securityCode = responseDict.validatedValue("security_code", expected: "" as AnyObject) as! String
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
    
    func callAPIToResendOTP(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams["email"] = emailStr as AnyObject
        
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
