//
//  EditProfileViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 24/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import ImageIO
import Alamofire

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, PNG, JPEG, GIF, TIFF
}


class EditProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate, UIWebViewDelegate{

    //outlet
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var familyAccessBtn: UIButton!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
   
    @IBOutlet weak var collectionViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var updateProfileBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var webContainerView: UIView!
    
    //instance variable
    var selectedIndexList = [Int]()
    var isFromProfile = false
    var profileImageList = [AnyObject]()
    var userInfo = UserInfo()
    
    var isEdit = false
    var isFull = false
    var resumeUrl: URL!
    var isFromLogin = false
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialMethod()
        callAPIToFetchUserDetails()
        
        if isFromLogin {
            self.backBtn.isHidden = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethod(){
        self.profileImageView.layer.cornerRadius = 50
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.borderColor = APPORANGECOLOR.cgColor
        self.profileImageView.layer.borderWidth = 5
        
        collectionViewHeightConstant.constant = (WINDOW_WIDTH - 60) / 4 + 5
        
        self.topView.setShadow(radius: 4)
        updateProfileBtn.layer.setShadow(radius: updateProfileBtn.layer.frame.size.height / 2)
        
        //edit profile setup
        isEdit = true
        self.familyAccessBtn.isUserInteractionEnabled = true
        headerView.layer.frame = CGRect(x:0, y:0, width: WINDOW_WIDTH, height: 365)
        upperLabel.text = "Please provide your complete profile information where you can select what you would like to show the public vs what you would like to keep on your personal file."
        lowerLabel.text = "Add up to three profile pictures"
        
    }
    
    func openPicker(){
        
        let alertController = UIAlertController(title: "Select", message: "", preferredStyle: .alert)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self;
        imagePicker.allowsEditing = true
        
        let action1 = UIAlertAction(title: "Camera", style: .default) { (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: "Photo Library", style: .default) { (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func openOptionPicker(sender : UIButton, list:[String], title:String){
        
        if list.count == 0 {
            showAlert(title: "Warning", message: "\(title) list is empty. Please add from admin panel.", controller: self)
            return
        }
        
        DPPickerManager.shared.showPicker(title: "Select \(title)", selected: "", strings: list) { (value, index, cancel) in
            if !cancel {
                switch sender.tag {
                case 200:
                    //location 1
                    self.userInfo.location1Str =  "\(self.userInfo.stateList[index]["id"] ?? "" as AnyObject)"
                    self.userInfo.location2Str = " "
                    self.callAPIToFetchCityList(stateID: self.userInfo.location1Str ,isFrom: false)
                    break
                case 201:
                    //location 2
                    self.userInfo.location2Str = "\(self.userInfo.cityList[index]["id"] ?? "" as AnyObject)"
                    break
                case 206:
                    //fromlocation 1
                    self.userInfo.fromLocation1Str =  "\(self.userInfo.stateList[index]["id"] ?? "" as AnyObject)"
                    self.userInfo.fromLocation2Str = " "
                    self.callAPIToFetchCityList(stateID: self.userInfo.fromLocation1Str, isFrom:  true)
                    break
                case 207:
                    //fromlocation 2
                    self.userInfo.fromLocation2Str = "\(self.userInfo.fromCityList[index]["id"] ?? "" as AnyObject)"
                    break
                case 202:
                    //MILITARY
                    self.userInfo.militaryStr = "\(self.userInfo.militaryList[index]["id"] ?? "" as AnyObject)"
                    break
                case 203:
                    //political
                    self.userInfo.politicalAffiliationStr = "\(self.userInfo.politicalList[index]["id"] ?? "" as AnyObject)"
                    break
                case 204:
                    //religion
                    self.userInfo.religionStr = "\(self.userInfo.religionList[index]["id"] ?? "" as AnyObject)"
                    break
                case 205:
                    //lrelationship
                    self.userInfo.relationshipStatusStr = "\(self.userInfo.relationshipsList[index]["id"] ?? "" as AnyObject)"
                    break
                default:
                    break
                }
                self.profileTableView.reloadData()
            }
        }
    }
    
    //get name by id from list
    func getNameFromListWithID(strID:String, list:[Dictionary<String, AnyObject>]) -> String {
        
        for dict in list{
            if "\(dict["id"] ?? "-0" as AnyObject)" == strID{
                return dict["name"] as! String;
            }
        }
        return ""
    }
    
    func fillWithNAOfBlankField() {
        
        if userInfo.collegeStr.count == 0{
            userInfo.collegeStr = "N/A"
        }
        if userInfo.almaMatterStr.count == 0{
            userInfo.almaMatterStr = "N/A"
        }
        if userInfo.likesStr.count == 0{
            userInfo.likesStr = "N/A"
        }
        if userInfo.facebookProfile.count == 0{
            userInfo.facebookProfile = "N/A"
        }
        if userInfo.instagramProfile.count == 0{
            userInfo.instagramProfile = "N/A"
        }
        if userInfo.linkdinProfile.count == 0{
            userInfo.linkdinProfile = "N/A"
        }
        if userInfo.lastNameStr.count == 0{
            userInfo.lastNameStr = "N/A"
        }
        if userInfo.occupationStr.count == 0{
            userInfo.occupationStr = "N/A"
        }
        if userInfo.workWebsiteStr.count == 0{
            userInfo.workWebsiteStr = "N/A"
        }
        if userInfo.educationStr.count == 0{
            userInfo.educationStr = "N/A"
        }
        if userInfo.highSchoolStr.count == 0{
            userInfo.highSchoolStr = "N/A"
        }
        
        if userInfo.phone_number.count == 0{
            userInfo.phone_number = "N/A"
        }
        if userInfo.twitterProfile.count == 0{
            userInfo.twitterProfile = "N/A"
        }
        
    }
    
    //MARK: - UIWebView Delegate Methods
    public func webViewDidStartLoad(_ webView: UIWebView){
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView){
        self.indicatorView.isHidden = true
         self.indicatorView.stopAnimating()
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
    }
    
    //MARK: - DocumentPicker Delegate Methods
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        resumeUrl = myURL
        logInfo(message:"import result : \(myURL)")
        self.profileTableView.reloadData()
       
    }
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        logInfo(message:"view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - ImagePicker Delegate Methods
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if isFromProfile{
                self.profileImageView.image = pickedImage
                DispatchQueue.main.async {
                    self.callAPIToSaveProfileImage(isMaine: 1, image: pickedImage)
                }
            }else{
                self.profileImageList.append(pickedImage)
                DispatchQueue.main.async {
                    self.callAPIToSaveProfileImage(isMaine: 0, image: pickedImage)
                }
                
                if self.profileImageList.count == 4{
                    self.profileImageList.remove(at: 0)
                    isFull = true
                }
                self.imageCollectionView.reloadData()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 113 && (string.isEqual("") == true || str.length <= 10) {
            return true
        }else if textField.tag != 113 && (string.isEqual("") == true || str.length <= 100) {
            return true
        } else {
            return false
        }
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField.tag {
        case 100:
            userInfo.firstNameStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 101:
            userInfo.lastNameStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 102:
            userInfo.emailStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 103:
            userInfo.occupationStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 104:
            userInfo.workWebsiteStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 105:
            userInfo.educationStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 106:
            userInfo.highSchoolStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 107:
            userInfo.collegeStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 108:
            userInfo.almaMatterStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 109:
            userInfo.likesStr = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 110:
            userInfo.facebookProfile = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 111:
            userInfo.linkdinProfile = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 112:
            userInfo.instagramProfile = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 113:
            userInfo.phone_number = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
        case 115:
            userInfo.twitterProfile = (textField.text?.trimmingCharacters(in: .whitespaces))!
            break
            
        default:
            break
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
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addImageBtnAction(_ sender: Any) {
        isFromProfile = true
        self.openPicker()
    }
    
    @IBAction func fammilyMemberBtnAction(_ sender: Any) {
        
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "FamilyMemberListViewController") as! FamilyMemberListViewController
        self.navigationController?.pushViewController(objVC, animated: true)
        
    }
    
    @IBAction func familyMemberSwitchAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func closeWebViewBtnAction(_ sender: Any) {
        self.webContainerView.isHidden = true
    }
    
    @IBAction func updateProfileBtnAction(_ sender: Any) {
        
//        if self.profileImageList.count == 3 {
//            isFull = true
//        }
        
//        updateProfileBtn.isSelected = !updateProfileBtn.isSelected
//        if updateProfileBtn.isSelected {
//            //edit operation
//            updateProfileBtn.setTitle("SAVE AND CONTINUE ", for: .normal)
//            isEdit = true
//            self.familyAccessBtn.isUserInteractionEnabled = true
//            headerView.layer.frame = CGRect(x:0, y:0, width: WINDOW_WIDTH, height: 365)
//            upperLabel.text = "Please provide your complete profile information where you can select what you would like to show the public vs what you would like to keep on your personal file."
//            lowerLabel.text = "Add up to three profile pictures"
//        }else{
//            //save operation
//            callAPIToEditUserDetails()
//        }
        callAPIToEditUserDetails()
        
//        self.profileTableView.reloadData()
//        self.imageCollectionView.reloadData()
        
    }
    
    //MARK: - SelectorButton Action
    @objc func crossBtnAction(_ sender: UIButton){
        
        if sender.tag == -1{
            
        }else{
             callAPIToDeleteProfileImage(sender: sender)
        }
    }
    
    @objc func openDocumentPicker(sender: UIButton){
        
        let importMenu = UIDocumentMenuViewController(documentTypes: ["com.adobe.pdf","org.openxmlformats.wordprocessingml.document","com.microsoft.word.doc","com.microsoft.excel.xls","com.microsoft.powerpoint.​ppt"], in: .import)
        importMenu.delegate = self
        importMenu.popoverPresentationController?.sourceView = self.view
        importMenu.modalPresentationStyle = .formSheet
        
        self.present(importMenu, animated: false, completion: nil)
    }
    
    @objc func crossResumeBtnAction(sender: UIButton){
        callAPIToDeleteResume()
        resumeUrl = nil
        self.profileTableView.reloadData()
    }
    
    @objc func openResume(){
        
        let urlRequest = URLRequest(url: resumeUrl)
        self.myWebView?.loadRequest(urlRequest)
        self.webContainerView.isHidden = false
    }
    
    @objc func selectionBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag >= 300{
            
            switch sender.tag{
            case 301:
                userInfo.name_access = !userInfo.name_access
                break
            case 302:
                userInfo.email_access = !userInfo.email_access
                break
            case 303:
                userInfo.phone_access = !userInfo.phone_access
                break
            case 304:
                userInfo.city_id_access = !userInfo.city_id_access
                break
            case 305:
                userInfo.from_city_id_access = !userInfo.from_city_id_access
                break
            case 306:
                userInfo.occupation_access = !userInfo.occupation_access
                break
            case 308:
                userInfo.work_website_access = !userInfo.work_website_access
                break
            case 309:
                userInfo.education_access = !userInfo.education_access
                break
            case 310:
                userInfo.high_school_access = !userInfo.high_school_access
                break
            case 311:
                userInfo.college_access = !userInfo.college_access
                break
            case 312:
                userInfo.alma_matter_access = !userInfo.alma_matter_access
                break
            case 313:
                userInfo.likes_access = !userInfo.likes_access
                break
            case 314:
                userInfo.facebookAccess = !userInfo.facebookAccess
                break
            case 315:
                userInfo.linkdinAccess = !userInfo.linkdinAccess
                break
            case 316:
                userInfo.instagramAccess = !userInfo.instagramAccess
                break
            case 317:
                userInfo.twitterAccess = !userInfo.twitterAccess
                break
            case 318:
                userInfo.military_id_access = !userInfo.military_id_access
                break
            case 319:
                userInfo.political_id_access = !userInfo.political_id_access
                break
            case 320:
                userInfo.religion_id_access = !userInfo.religion_id_access
                break
            case 321:
                userInfo.relationship_id_access = !userInfo.relationship_id_access
                break
            default:
                break
            }
            
            self.profileTableView.reloadData()
            return
        }
        
        switch sender.tag {
        case 200:
            var list = [String]()
            for dict in userInfo.stateList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "State")
            break
        case 201:
            var list = [String]()
            for dict in userInfo.cityList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "City")
            break
        case 206:
            var list = [String]()
            for dict in userInfo.stateList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "State")
            break
        case 207:
            var list = [String]()
            for dict in userInfo.fromCityList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "City")
            break
        case 202:
            var list = [String]()
            for dict in userInfo.militaryList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "Military")
            break
        case 203:
            var list = [String]()
            for dict in userInfo.politicalList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "Political")
            break
        case 204:
            var list = [String]()
            for dict in userInfo.religionList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
             self.openOptionPicker(sender: sender, list: list, title: "Religion")
            break
        case 205:
            var list = [String]()
            for dict in userInfo.relationshipsList{
                list.append(dict.validatedValue("name", expected: "" as AnyObject) as! String)
            }
            self.openOptionPicker(sender: sender, list: list, title: "Relationship")
            break
        default:
            break
        }
    }
    
    //MARK: - UICollectionViewDelegate and DataSource Methods
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return profileImageList.count < 3 ? profileImageList.count + 1 : profileImageList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (WINDOW_WIDTH - 60) / 4, height: (WINDOW_WIDTH - 60) / 4)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        isFromProfile = false
        if self.profileImageList.count < 3{
            self.openPicker()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell : ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        var index = indexPath.row
       
        cell.profileImageView.layer.cornerRadius = ((WINDOW_WIDTH - 60) / 4) / 2
        cell.profileImageView.layer.masksToBounds = true
        
        if profileImageList.count < 3 {
            index -= 1
        }
        
        cell.crossBtn.tag = index
        cell.crossBtn.addTarget(self, action: #selector(self.crossBtnAction(_:)), for: .touchUpInside)
        
        if profileImageList.count < 3 && indexPath.row == 0{
            cell.crossBtn.isHidden = true
            cell.profileImageView.image = #imageLiteral(resourceName: "add_big")
            return cell
        }else{
            cell.crossBtn.isHidden = !isEdit
        }
      
        if profileImageList[index].isKind(of: UIImage.self) {
            cell.profileImageView.image = profileImageList[index] as? UIImage
        }else{
            cell.profileImageView.sd_setImage(with: URL.init(string: (profileImageList[index] as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String)!, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
        }
        
        cell.isUserInteractionEnabled = isEdit
        return cell
    }
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return 22
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.row == 7{
            return 90
        }else if indexPath.row == 4 || indexPath.row == 5{
            return 100
        }
        return 80
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
 
        if indexPath.row == 4 || indexPath.row == 5{
            
            let cell : DoubleTextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextFieldTableViewCell") as! DoubleTextFieldTableViewCell
            cell.firstTextField.delegate = self
            cell.secondTextField.delegate = self
            cell.firstTextField.placeholder = "State Selection";
            cell.secondTextField.placeholder = "City Selection ";
            cell.notificationBTn.tag = indexPath.row + 300
            cell.notificationBTn.addTarget(self, action: #selector(self.selectionBtnAction(_:)), for: .touchUpInside)
            cell.firstSelectionBtn.isHidden = false
            cell.secondSelectionBtn.isHidden = false
            
            if indexPath.row == 4 {
                cell.firstSelectionBtn.tag = 200
                cell.secondSelectionBtn.tag = 201
                cell.firstTextField.text = self.getNameFromListWithID(strID: userInfo.location1Str, list: userInfo.stateList)
                cell.secondTextField.text = self.getNameFromListWithID(strID: userInfo.location2Str, list: userInfo.cityList)
                cell.notificationBTn.isSelected = userInfo.city_id_access
                cell.titleLabel.text = "Currently Lives In:"

            }else {
                cell.firstSelectionBtn.tag = 206
                cell.secondSelectionBtn.tag = 207
                cell.firstTextField.text = self.getNameFromListWithID(strID: userInfo.fromLocation1Str, list: userInfo.stateList)
                cell.secondTextField.text = self.getNameFromListWithID(strID: userInfo.fromLocation2Str, list: userInfo.fromCityList)
                cell.notificationBTn.isSelected = userInfo.from_city_id_access
                cell.titleLabel.text = "From:"

            }
           
            cell.firstSelectionBtn.addTarget(self, action: #selector(self.selectionBtnAction(_:)), for: .touchUpInside)
            cell.secondSelectionBtn.addTarget(self, action: #selector(self.selectionBtnAction(_:)), for: .touchUpInside)
            cell.privateLabel.isHidden = true
            
            cell.isUserInteractionEnabled = isEdit
            return cell
        }else{
            
            let cell : SingleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SingleTableViewCell") as! SingleTableViewCell
            cell.separatorLabel.isHidden = false;
            cell.selectionBtn.isHidden = true;
            cell.inputTextField.delegate = self;
            cell.selectionBtn.addTarget(self, action: #selector(self.selectionBtnAction(_:)), for: .touchUpInside)
            cell.notificationBtn.addTarget(self, action: #selector(self.selectionBtnAction(_:)), for: .touchUpInside)
            cell.notificationBtn.tag = indexPath.row + 300
            cell.inputTextField.returnKeyType = .next
            cell.notificationBtn.isHidden = false
            cell.inputTextField.isUserInteractionEnabled = true
            cell.inputTextField.keyboardType = .default
            if selectedIndexList.contains(indexPath.row){
                cell.notificationBtn.isSelected = true
            }else{
                cell.notificationBtn.isSelected = false
            }
            
            switch indexPath.row{
                
            case 0:
                cell.inputTextField.placeholder = "First Name"
                cell.inputTextField.tag = 100
                cell.inputTextField.text = userInfo.firstNameStr
                //cell.notificationBtn.isSelected = userInfo.name_access
                cell.notificationBtn.isHidden = true;
                break
            case 1:
                cell.inputTextField.placeholder = "Last Name"
                cell.inputTextField.tag = 101
                cell.inputTextField.text = userInfo.lastNameStr
                cell.notificationBtn.isSelected = userInfo.name_access
                break
                
            case 2:
                cell.inputTextField.placeholder = "Email"
                cell.inputTextField.tag = 102
                cell.inputTextField.text = userInfo.emailStr
                cell.notificationBtn.isSelected = userInfo.email_access
                cell.inputTextField.isUserInteractionEnabled = false

                break
            case 3:
                cell.inputTextField.placeholder = "Phone Number"
                cell.inputTextField.tag = 113
                cell.inputTextField.text = userInfo.phone_number
                cell.notificationBtn.isSelected = userInfo.phone_access
                cell.inputTextField.keyboardType = .numberPad
                
                break
            case 6:
                cell.inputTextField.placeholder = "Occupation"
                cell.inputTextField.tag = 103
                cell.inputTextField.text = userInfo.occupationStr
                cell.notificationBtn.isSelected = userInfo.occupation_access
                break
            case 7:
                let uploadCell: UploadTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UploadTableViewCell") as! UploadTableViewCell
                uploadCell.openResumeBtn.layer.borderColor = UIColor.lightGray.cgColor
                uploadCell.icloudBtn.addTarget(self, action: #selector(self.openDocumentPicker), for: .touchUpInside)
                uploadCell.dropboxUploadBtn.addTarget(self, action: #selector(self.openDocumentPicker), for: .touchUpInside)
                uploadCell.driveUploadBtn.addTarget(self, action: #selector(self.openDocumentPicker), for: .touchUpInside)
                uploadCell.fileUploadBtn.addTarget(self, action: #selector(self.openDocumentPicker), for: .touchUpInside)
                uploadCell.deleteResumeBtn.addTarget(self, action: #selector(self.crossResumeBtnAction(sender:)), for: .touchUpInside)
                uploadCell.openResumeBtn.addTarget(self, action: #selector(self.openResume), for: .touchUpInside)

                if resumeUrl != nil{
                    uploadCell.openResumeBtn.isHidden = false
                    uploadCell.deleteResumeBtn.isHidden = false
                }else{
                    uploadCell.openResumeBtn.isHidden = true
                    uploadCell.deleteResumeBtn.isHidden = true
                }
                
                return uploadCell
            case 8:
                cell.inputTextField.placeholder = "Work Website"
                cell.inputTextField.tag = 104
                cell.inputTextField.text = userInfo.workWebsiteStr
                cell.notificationBtn.isSelected = userInfo.work_website_access
                break
            case 9:
                cell.inputTextField.placeholder = "Education"
                cell.inputTextField.tag = 105
                cell.inputTextField.text = userInfo.educationStr
                cell.notificationBtn.isSelected = userInfo.education_access
                break
            case 10:
                cell.inputTextField.placeholder = "High School"
                cell.inputTextField.tag = 106
                cell.inputTextField.text = userInfo.highSchoolStr
                cell.notificationBtn.isSelected = userInfo.high_school_access
                break
            case 11:
                cell.inputTextField.placeholder = "College"
                cell.inputTextField.tag = 107
                cell.inputTextField.text = userInfo.collegeStr
                cell.notificationBtn.isSelected = userInfo.college_access
                break
            case 12:
                cell.inputTextField.placeholder = "Alma Matter"
                cell.inputTextField.tag = 108
                cell.inputTextField.text = userInfo.almaMatterStr
                cell.notificationBtn.isSelected = userInfo.alma_matter_access
                break
            case 13:
                cell.inputTextField.placeholder = "Likes/Hobbies/Interests"
                cell.inputTextField.tag = 109
                cell.inputTextField.text = userInfo.likesStr
                cell.notificationBtn.isSelected = userInfo.likes_access
                
                break
            case 14:
                cell.inputTextField.placeholder = "Facebook Profile"
                cell.inputTextField.tag = 110
                cell.inputTextField.text = userInfo.facebookProfile
                cell.notificationBtn.isSelected = userInfo.facebookAccess
                break
            case 15:
                cell.inputTextField.placeholder = "Linkedin Profile"
                cell.inputTextField.tag = 111
                cell.inputTextField.text = userInfo.linkdinProfile
                cell.notificationBtn.isSelected = userInfo.linkdinAccess
                
                break
            case 16:
                cell.inputTextField.placeholder = "Instagram Profile"
                cell.inputTextField.tag = 112
                cell.inputTextField.text = userInfo.instagramProfile
                cell.notificationBtn.isSelected = userInfo.instagramAccess
                break
            case 17:
                cell.inputTextField.placeholder = "Twitter Profile"
                cell.inputTextField.tag = 115
                cell.inputTextField.text = userInfo.twitterProfile
                cell.notificationBtn.isSelected = userInfo.twitterAccess
                cell.inputTextField.returnKeyType = .done
                break
            case 18:
                cell.inputTextField.placeholder = "Military"
                //cell.inputTextField.tag = 110
                cell.selectionBtn.isHidden = false
                cell.selectionBtn.tag = 202
                cell.inputTextField.text = self.getNameFromListWithID(strID: userInfo.militaryStr, list: userInfo.militaryList)
                cell.notificationBtn.isSelected = userInfo.military_id_access
                break
            case 19:
                cell.inputTextField.placeholder = "Political Affiliation"
                cell.selectionBtn.isHidden = false
                cell.selectionBtn.tag = 203
                cell.inputTextField.text = self.getNameFromListWithID(strID: userInfo.politicalAffiliationStr, list: userInfo.politicalList)
                cell.notificationBtn.isSelected = userInfo.political_id_access
                break
            case 20:
                cell.inputTextField.placeholder = "Religion"
                cell.selectionBtn.isHidden = false
                cell.selectionBtn.tag = 204
                cell.inputTextField.text = self.getNameFromListWithID(strID: userInfo.religionStr, list: userInfo.religionList)
                cell.notificationBtn.isSelected = userInfo.religion_id_access
                break
            case 21:
                cell.inputTextField.placeholder = "Relationship"
                cell.selectionBtn.isHidden = false
                cell.selectionBtn.tag = 205
                cell.inputTextField.text = self.getNameFromListWithID(strID: userInfo.relationshipStatusStr, list: userInfo.relationshipsList)
                cell.notificationBtn.isSelected = userInfo.relationship_id_access
                break
            default:
                break
            }
            
            cell.isUserInteractionEnabled = isEdit
            return cell
        }
    }
    
    //MARK: - Service Helper Methods
    //Call Api to Fetch Profile details
    func callAPIToFetchUserDetails(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        hideHud()
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kProfileAPI) { (response, error) in
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
                    
                    self.userInfo = UserInfo.getUserDetailsWithDict(dict: responseDict.validatedValue(kData, expected: [:] as AnyObject) as! Dictionary<String, AnyObject>)
                    if self.userInfo.profileImageList.count >= 3{
                        self.profileImageList.removeAll()
                    }
                    
                    for dict in self.userInfo.profileImageList{
                        self.profileImageList.append(dict["name"]!)
                    }
                    DispatchQueue.main.async {
                        self.familyAccessBtn.isSelected = self.userInfo.familyAccess
                        self.profileImageView.sd_setImage(with: URL.init(string: self.userInfo.profileImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
                        self.resumeUrl = self.userInfo.resumeURL
                        
                        if self.resumeUrl != nil{
                            let urlRequest = URLRequest(url: self.resumeUrl)
                            self.myWebView?.loadRequest(urlRequest)
                        }
                        
                        self.profileTableView.reloadData()
                        self.imageCollectionView.reloadData()
                    }
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
        
    }
    
    //Call Api to Edit Profile details
    func callAPIToEditUserDetails(){
        
        self.fillWithNAOfBlankField()
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["first_name"] = userInfo.firstNameStr as AnyObject
        dictParams["last_name"] = userInfo.lastNameStr as AnyObject
        dictParams["email"] = userInfo.emailStr as AnyObject
        dictParams["email_access"] = userInfo.email_access as AnyObject
        dictParams["state_id"] = userInfo.location1Str as AnyObject
        
        dictParams["city_id"] = userInfo.location2Str as AnyObject
        dictParams["city_id_access"] = userInfo.city_id_access as AnyObject
        dictParams["occupation"] = userInfo.occupationStr as AnyObject
        dictParams["occupation_access"] = userInfo.occupation_access as AnyObject
        dictParams["work_website"] = userInfo.workWebsiteStr as AnyObject
        dictParams["work_website_access"] = userInfo.work_website_access as AnyObject
        dictParams["education"] = userInfo.educationStr as AnyObject
        
        dictParams["education_access"] = userInfo.education_access as AnyObject
        dictParams["high_school"] = userInfo.highSchoolStr as AnyObject
        dictParams["high_school_access"] = userInfo.high_school_access as AnyObject
        dictParams["college"] = userInfo.collegeStr as AnyObject
        dictParams["college_access"] = userInfo.college_access as AnyObject
        dictParams["alma_matter"] = userInfo.almaMatterStr as AnyObject
        dictParams["alma_matter_access"] = userInfo.alma_matter_access as AnyObject
       
        dictParams["likes"] = userInfo.likesStr as AnyObject
        dictParams["likes_access"] = self.userInfo.likes_access as AnyObject
        dictParams["military_id"] = userInfo.militaryStr as AnyObject
        dictParams["military_id_access"] = userInfo.military_id_access as AnyObject
        dictParams["political_id"] = userInfo.politicalAffiliationStr as AnyObject
        dictParams["political_id_access"] = userInfo.political_id_access as AnyObject
       
        dictParams["religion_id"] = userInfo.religionStr as AnyObject
        dictParams["religion_id_access"] = userInfo.religion_id_access as AnyObject
        dictParams["relationship_id"] = userInfo.relationshipStatusStr as AnyObject
        dictParams["relationship_id_access"] = userInfo.relationship_id_access as AnyObject
        dictParams["last_name_access"] = userInfo.name_access as AnyObject
        dictParams["family_access"] = self.familyAccessBtn.isSelected as AnyObject

        dictParams["fb_link"] = userInfo.facebookProfile as AnyObject
        dictParams["fb_link_access"] = userInfo.facebookAccess as AnyObject
        dictParams["insta_link"] = userInfo.instagramProfile as AnyObject
        dictParams["insta_link_access"] = userInfo.instagramAccess as AnyObject
        dictParams["linked_in_link"] = userInfo.linkdinProfile as AnyObject
        dictParams["linked_in_link_access"] = userInfo.linkdinAccess as AnyObject
        dictParams["phone"] = userInfo.phone_number as AnyObject
        dictParams["phone_access"] = userInfo.phone_access as AnyObject
        dictParams["twit_link"] = userInfo.twitterProfile as AnyObject
        dictParams["twit_link_access"] = userInfo.twitterAccess as AnyObject
        
        dictParams["from_state_id"] = userInfo.fromLocation1Str as AnyObject
        
        dictParams["from_city_id"] = userInfo.fromLocation2Str as AnyObject
        dictParams["from_city_id_access"] = userInfo.from_city_id_access as AnyObject
        
        var data : Data!
        if resumeUrl != nil{
            do {
                data = try Data(contentsOf: resumeUrl)
                logInfo(message:"data is ")
            } catch {
                
            }
        }
        
        ServiceHelper.sharedInstance.createRequestToUploadDataWithString(additionalParams: dictParams, dataContent: data , strName: "resume", strFileName: "sample.pdf", strType: "application/pdf", apiName: kProfileEditAPI, completion: { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    UserDefaults.standard.set(false, forKey: "isEdit")
                    UserDefaults.standard.synchronize()
                    
                    if self.isFromLogin {
                        showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self, acceptBlock: {
                            let objVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                            self.navigationController?.pushViewController(objVC, animated: true)
                            
                        })
                    }else{
                        showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                    }
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        })

    }

    //call api to fetch city list
    func callAPIToFetchCityList(stateID:String, isFrom:Bool){
       
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams["state_id"] = stateID as AnyObject
        
        hideHud()
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kGetCityListAPI) { (response, error) in
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
                    
                    if isFrom {
                        
                        self.userInfo.fromCityList = responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]

                    }else{
                        self.userInfo.cityList = responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
                    }
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    //call api to save profile image
    func callAPIToSaveProfileImage(isMaine:Int, image:UIImage){
        
        userInfo.cityList.removeAll()
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["image_type"] = isMaine as AnyObject
       let imgData = UIImageJPEGRepresentation(image, 0.1)!

        ServiceHelper.sharedInstance.createRequestToUploadDataWithString(additionalParams: dictParams, dataContent: imgData , strName: "image", strFileName: "image1.jpg", strType: "image/jpg", apiName: kUploadProfileImageAPI, completion: { (response, error) in
            if error != nil {
                 showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                 return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    if isMaine == 0{
                        self.userInfo.profileImageList.append(["id":(responseDict.validatedValue(kData, expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("id", expected: "" as AnyObject)  as AnyObject, "name":(responseDict.validatedValue(kData, expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("image", expected: "" as AnyObject) as AnyObject])
                    }
                    showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        })
    }
    
    func callAPIToDeleteProfileImage(sender:UIButton){
        
        userInfo.cityList.removeAll()
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        if isFull {
            
        }else{
            
        }
        dictParams["user_image_id"] = userInfo.profileImageList[sender.tag].validatedValue("id", expected: "" as AnyObject) as AnyObject
 
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kDeleteProfileGalleryAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    self.userInfo.profileImageList.remove(at: sender.tag)
                    self.profileImageList.remove(at: sender.tag)

                    self.imageCollectionView.reloadData()
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
    
    func callAPIToDeleteResume(){
        
        userInfo.cityList.removeAll()
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: false, params: dictParams , apiName: kAPIToDeleteResume) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
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

extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else if buffer == ImageHeaderData.GIF
        {
            return .GIF
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else{
            return .Unknown
        }
    }
}
