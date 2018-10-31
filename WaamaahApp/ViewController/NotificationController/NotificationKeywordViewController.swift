//
//  NotificationKeywordViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 25/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class NotificationKeywordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    //outlet
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var timeTextField: UITextField!
    
    //instance variable
    var selectedIndex: Int = -1
    var isFromSetting = true
    var keywordList = [FilterInfo]()
    var timeStr :String = ""
    var footerBtn = UIButton()
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        isFromSetting = true
        self.initialMethods()
        callAPIToFetchKeywords()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethods(){
        
        self.topView.setShadow(radius: 0)
        
    }
    
    //get selected ids
    func getSelectedIdS() -> String{
        var selectedList = [String]()
        for obj in keywordList{
            if obj.isSelected{
                selectedList.append(obj.idStr)
            }
        }
        return selectedList.joined(separator: ",")
    }
    
    //MARK: - UITextField Delegate Methods
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
    
    //MARK: - UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if string.isEqual("") == true || str.length <= 6 {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        timeStr = textField.text!
        
    }
    
    //MARK: - IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        logInfo(message:"great...")
    }
   
    @objc func saveSelectedKeyWords(){
        self.view.endEditing(true)
        callAPIToSaveSelectedKeywords()
    }
    
    //MARK: - UICollectionView Delegate and DataSource Methods
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.keywordList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
         return CGSize(width: 0, height: 0)
        if isFromSetting{
            return CGSize(width: self.myCollectionView.bounds.width, height: 180)
        }else{
            return CGSize(width: self.myCollectionView.bounds.width, height: 100)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if indexPath.item == keywordList.count {
            if isFromSetting{
                return CGSize(width: self.myCollectionView.bounds.width, height: 180)
            }else{
                return CGSize(width: self.myCollectionView.bounds.width, height: 100)
            }
        }
        return CGSize(width: (collectionView.frame.width - 10) / 2 , height: 65)
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let obj = keywordList[indexPath.row]
        obj.isSelected = !obj.isSelected
        self.myCollectionView.reloadData()
    }
   
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView   = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionViewCell", for: indexPath) as! HeaderCollectionViewCell
            
            if isFromSetting {
                headerView.titleLabel.text = "Please select from the following options which matches you would like to be notified of when someone comes into close range."
                
            }else{
               headerView.titleLabel.text = "Select profile keywords for which you would like to be notified when a match is found within close contact."
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        logInfo(message:"greatt----------0")
        // handling code
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        
        if indexPath.row == keywordList.count {
            let cell: FooterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FooterCollectionViewCell", for: indexPath) as! FooterCollectionViewCell
            
            if isFromSetting {
                cell.contentContainerView.isHidden = false
                
            }else{
                cell.contentContainerView.isHidden = true
                
            }
            cell.timeTextfield.text = timeStr
            cell.timeTextfield.delegate = self
            cell.timeTextfield.keyboardType = .numberPad
            cell.saveButton.isUserInteractionEnabled = true
            cell.saveButton.addTarget(self, action: #selector(saveSelectedKeyWords), for: .touchUpInside)
            
            return cell
        }
        
        let cell: ImageLabelCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageLabelCollectionViewCell", for: indexPath) as! ImageLabelCollectionViewCell
        
        let obj = keywordList[indexPath.row]
        
        if obj.isSelected{
            cell.checkImageView.isHidden = false
            cell.containerView.backgroundColor = APPORANGECOLOR
        }else{
            cell.checkImageView.isHidden = true
            cell.containerView.backgroundColor = UIColor.init(red: (244.0/255.0), green: (244.0/255.0), blue: (244.0/255.0), alpha: 1.0)
        }
        
        cell.titleLabel.text = obj.nameStr
        
        cell.containerView.layer.shadowColor = UIColor.darkGray.cgColor
        cell.containerView.layer.shadowOffset = CGSize(width: 1,height: 1)
        cell.containerView.layer.shadowRadius = 2.0
        cell.containerView.layer.shadowOpacity = 0.5
        cell.containerView.layer.cornerRadius = 6
        cell.containerView.layer.masksToBounds = false
        return cell
    }
    
    //MARK: - Service Helper Methods
    //Fetch All keywords
    func callAPIToFetchKeywords(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        
        //create_user
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kCaptureOptionsAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    self.keywordList = FilterInfo.getKeywordList(list: responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>])
                    let n = (responseDict.validatedValue("capture_time_period", expected: 0 as AnyObject) as! Int)
                    self.timeStr = "\(n)"
                    self.myCollectionView.reloadData()
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    //Save keyword with time period
    func callAPIToSaveSelectedKeywords(){
        
        if timeStr.trimmingCharacters(in: .whitespaces).count == 0 {
            showAlert(title: "Warning", message: "Please enter minutes", controller: self)
            return
        }
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["capture_filter_ids"] = getSelectedIdS() as AnyObject
        dictParams["capture_time_period"] = timeStr as AnyObject

        //create_user
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kCaptureOptionsEditAPI) { (response, error) in
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
