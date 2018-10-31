//
//  ProfileDetailsViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 27/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import SDWebImage
import MessageUI

class ProfileDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, RequestPopupProtocol, MFMailComposeViewControllerDelegate {

    //MARK: - IBOutLet and Instance vairiables
    
    @IBOutlet weak var firstContainerHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var friendRequestBtn: UIButton!
   

    @IBOutlet weak var placeHolderImageview: UIImageView!
    @IBOutlet weak var countMutualFriendlabel: UILabel!
    @IBOutlet weak var secondContainerHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewMoreBtn: UIButton!
    @IBOutlet weak var collectionViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var secondContentContainerView: UIView!
    @IBOutlet weak var secondContentTableView: UITableView!
    @IBOutlet weak var firstContentTabelviewContainer: UIView!
    @IBOutlet weak var firstContentTableView: UITableView!
    @IBOutlet weak var friendCollectionView: UICollectionView!
    @IBOutlet weak var friendListContaainerView: UIView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var carausalCollectionView: UICollectionView!
    @IBOutlet weak var profileTableView: UITableView!
    
    //familyCollection outlet
    @IBOutlet weak var familyCountLabel: UILabel!
    @IBOutlet weak var familyMoreBtn: UIButton!
    @IBOutlet weak var familyCollectionView: UICollectionView!
    @IBOutlet weak var familyMemberContainerView: UIView!
    @IBOutlet weak var familyContainerViewHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var webContainerView: UIView!
    
    //instace variable
    fileprivate var items = [Character]()
    var isFriend:Int = 0
    var firstDetailsArray = [Dictionary<String,AnyObject>]()
    var secondDetailsArray = [Dictionary<String,AnyObject>]()
    var mutualFriend = [FriendInfo]()
    var profileUserID: String = ""
    var profileDict = Dictionary<String, AnyObject>()
    var profileImageList = [Dictionary<String, AnyObject>]()
    var familyFriends = [FriendInfo]()
    var occupationPosition = -1
    var resumeUrl: URL!
    var friendRquestStstus = FriendRequestStatus.Friend
    var requestStatus: String = ""
    var mobileNumberIndex = -1
    var emailIDIndex = -1

    //MARK: - UILifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethods()
        self.setupLayout()
        self.items = self.createItems()
        self.currentPage = 0
        callAPIToGetCapturedUsers()
        self.placeHolderImageview.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        let indexPath = IndexPath.init(row: 2, section: 0)
//        self.carausalCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
//            let visibleItems: NSArray = self.carausalCollectionView.indexPathsForVisibleItems as NSArray
//            let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
//            let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
//            self.carausalCollectionView.scrollToItem(at: nextItem, at: .right, animated: true)
//        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethods(){

        topView.setShadow(radius: 0)
        friendListContaainerView.setShadow(radius: 4)
        firstContentTabelviewContainer.setShadow(radius: 4)
        secondContentContainerView.setShadow(radius: 4)
        familyMemberContainerView.setShadow(radius: 4)
        chatBtn.layer.setShadow(radius: chatBtn.layer.frame.size.height / 2)
        
        self.resetFriendStatusBtn()
        self.profileNameLabel.text = ""
        
        
    }
    
    
    
    func resetFriendStatusBtn(){
    
        if requestStatus == "FRIEND" {
            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "unfriend"), for: .normal)
        }else if requestStatus == "REQ_SENT"{
            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "unfriend"), for: .normal)
        }else if requestStatus == "REQ_RECEIVED"{
            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "friendRequest"), for: .normal)
        }else{
            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "request_send"), for: .normal)
        }
        
//        switch self.friendRquestStstus {
//        case .Friend:
//            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "unfriend"), for: .normal)
//        case .FriendRequestSend:
//            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "cancel_request"), for: .normal)
//        case .Unfriend:
//            self.friendRequestBtn.setImage(#imageLiteral(resourceName: "request_send"), for: .normal)
//        default:
//            break;
//        }
    }
    
    fileprivate func setupLayout() {
     
        let layout = self.carausalCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 30)
    }
    
    fileprivate func createItems() -> [Character] {
        let characters = [
            Character(imageName: "profile", name: "Wall-E", movie: "Wall-E"),
            Character(imageName: "profile", name: "Nemo", movie: "Finding Nemo"),
            Character(imageName: "profile", name: "Remy", movie: "Ratatouille"),
            Character(imageName: "profile", name: "Buzz Lightyear", movie: "Toy Story"),
            Character(imageName: "profile", name: "Mike & Sullivan", movie: "Monsters Inc.")
        ]
        return characters
    }
    
    fileprivate var currentPage: Int = 0 {
        didSet {
//            let character = self.items[self.currentPage]
//            self.profileNameLabel.text = character.name.uppercased()
        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.carausalCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    fileprivate var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    func launchEmail() {
        
        let emailTitle = "Hi \(self.profileDict.validatedValue(kFirstName, expected: "" as AnyObject))-Sent from Whaabaam"
        
        let messageBody = "\n\n\n\nRegards\n \(UserDefaults.standard.value(forKey: kFirstName) as! String) \(UserDefaults.standard.value(forKey: kLastName) as! String) \n Sent from Whaabaam"
        
        let toRecipents = ["\(firstDetailsArray[emailIDIndex].validatedValue("title", expected: "" as AnyObject))"]
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
    
    //MARK:- IBAction Methods
    @IBAction func noteBtnAction(_ sender: Any) {
        let obj = profileStoryboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        obj.friendUserID = self.profileUserID
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    @IBAction func resumeCrossBtn(_ sender: Any) {
        self.webContainerView.isHidden = true
    }
    
    @IBAction func familyViewMoreBtnAction(_ sender: Any) {
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ViewMoreContactViewController") as! ViewMoreContactViewController
        objVC.titleString = "Family Member"
        objVC.profileUserID = self.profileUserID
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func unfriendBtnAction(_ sender: Any) {
        
      
        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        objVC.popupDelegate = self
        if self.requestStatus == "FRIEND" {
            objVC.friendRequestStatus = FriendRequestStatus.IsUnfriendOfFriend
            objVC.messageString = "Are you sure want to unfriend?"
            
        }else if self.requestStatus == "REQ_SENT"{
            objVC.messageString = "Are you sure want to cancel friend request?"
            objVC.isFromRequestSend = false
            objVC.friendRequestStatus = FriendRequestStatus.IsCancelFriendRequest
            objVC.popupDelegate = self
          
        }else if self.requestStatus == "REQ_RECEIVED"{
            
            objVC.messageString = "Are you sure want to accept request?"
            objVC.isFromRequestSend = false
            objVC.popupDelegate = self
            objVC.isFromApproveReject = true
         
        }else{
            objVC.messageString = "Are you sure want to send a connection request?"
            objVC.isFromRequestSend = false
            objVC.popupDelegate = self
            
        }
        objVC.modalPresentationStyle = .overFullScreen
        self.present(objVC, animated: true, completion: nil)
        
        
//        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
//        objVC.popupDelegate = self
//
//        switch self.friendRquestStstus {
//        case .Friend:
//            objVC.friendRequestStatus = FriendRequestStatus.IsUnfriendOfFriend
//            objVC.messageString = "Are you sure want to unfriend \(profileDict.validatedValue("first_name", expected: "" as AnyObject)) ?"
//        case .FriendRequestSend:
//            objVC.friendRequestStatus = FriendRequestStatus.IsCancelFriendRequest
//             objVC.messageString = "Are you sure want to cancel friend request?"
//
//        case .Unfriend:
//             objVC.messageString = "Are you sure want to send \(profileDict.validatedValue("first_name", expected: "" as AnyObject)) friend request?"
//        default:
//            break
//        }
//        objVC.modalPresentationStyle = .overFullScreen
//        self.present(objVC, animated: true, completion: nil)
       
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func contactViewMoreBtnAction(_ sender: Any) {
        
        let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ViewMoreContactViewController") as! ViewMoreContactViewController
        objVC.titleString = "Mutual Contact"
        objVC.profileUserID = self.profileUserID
        self.navigationController?.pushViewController(objVC, animated: true)
        
    }
    
    
    @IBAction func chatBtnAction(_ sender: Any) {
        
        if isFriend == 0 {
            showAlert(title: "Warning", message: "Please make sure, \(profileDict.validatedValue("first_name", expected: "" as AnyObject)) is your friend.", controller: self)

        }else{

            APPDELEGATE.createNewDailog(quickBloxId: UInt(profileDict.validatedValue("quickblox_id", expected: "" as AnyObject) as! String)!)
        }
    }
    
    
    
    
    //MARK: - Selector Methods
    @objc func viewResume(){
        let urlRequest = URLRequest(url: resumeUrl)
        self.myWebView?.loadRequest(urlRequest)
        self.webContainerView.isHidden = false
    }
    
    //MARK: - Friend Popup Delegate
    func sendFriendRequest(){
        callAPIToSendFriendRequest()
    }
    
    func cancelFriendRequest(){
        callAPIToCancelFriendRequest()
    }
    
    func unFriendOfFriend() {
        callAPIToUnFrinedUser()
    }
    
    func rejectFriendrequest() {
        callAPIToAcceptFriendRequest(action: "A")
    }
    
    // MARK: - Card Collection Delegate & DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == self.carausalCollectionView {
            return profileImageList.count
        }else if collectionView == self.familyCollectionView{
            return familyFriends.count
        }else{
            return mutualFriend.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if collectionView != self.carausalCollectionView {
            return CGSize(width: 60, height: 100)
        }
        return CGSize(width: 140, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.carausalCollectionView {
            let cell: CarouselCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell", for: indexPath) as! CarouselCollectionViewCell
            //let character = items[(indexPath as NSIndexPath).row]
            let dict = profileImageList[indexPath.row];
            cell.image.sd_setImage(with: URL.init(string: (dict.validatedValue("name", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
            
            return cell
        }else{
            let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
            var obj: FriendInfo!
            if collectionView == familyCollectionView {
                obj = familyFriends[indexPath.row];
            }else{
                obj = mutualFriend[indexPath.row]
            }

            cell.profileImageView.sd_setImage(with: URL.init(string: obj.fUserImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
           // cell.crossBtn.isHidden = true
            cell.nameLabel.text = obj.fUserFirstName
            cell.profileImageView.layer.cornerRadius = 30
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView != carausalCollectionView{
           
            var obj: FriendInfo!
            if collectionView == familyCollectionView {
                obj = familyFriends[indexPath.row];
            }else{
                obj = mutualFriend[indexPath.row]
            }
            
            let objVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
            objVC.profileUserID = obj.fFriendUserID
            
            if obj.fRequestStatus == "FRIEND" {
                objVC.isFriend = 1
            }else{
                objVC.isFriend = 0
            }
            
            self.navigationController?.pushViewController(objVC, animated: true)
        }
        
        if collectionView == carausalCollectionView {

            let dict = profileImageList[indexPath.row];
            
            let objVC = ImageZoomViewController.init(nibName: "ImageZoomViewController", bundle: nil) as! ImageZoomViewController
            objVC.imageURl = (dict.validatedValue("name", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String
            objVC.modalPresentationStyle = .overFullScreen
            
            self.present(objVC, animated: true, completion: nil)
            
//            scrollImageView.sd_setImage(with: URL.init(string: (dict.validatedValue("name", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
//            self.scrollViewContainer.isHidden = false

            
        }
        
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.carausalCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    //MARK: - UITableView Delegate and DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView == self.firstContentTableView{
            return firstDetailsArray.count
        }
        if tableView == self.secondContentTableView{
            return secondDetailsArray.count
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if tableView == firstContentTableView{
            if indexPath.row == mobileNumberIndex{
                guard let url = URL.init(string: "tel://\(firstDetailsArray[mobileNumberIndex].validatedValue("title", expected: "" as AnyObject))") else{
                    return
                }
         
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }else if indexPath.row == emailIDIndex{
                self.launchEmail()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
      
        let cell: ImageLabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ImageLabelTableViewCell") as! ImageLabelTableViewCell
        cell.separatorLabel.isHidden = false
        cell.titelLabel.textColor = UIColor.black
        var dict = Dictionary<String, AnyObject>()
        
        if tableView == self.firstContentTableView {
            dict = firstDetailsArray[indexPath.row]
            
            if indexPath.row == mobileNumberIndex {
                cell.titelLabel.textColor = APPORANGECOLOR
            }else if indexPath.row == emailIDIndex{
                cell.titelLabel.textColor = APPORANGECOLOR
            }
            if indexPath.row == (firstDetailsArray.count - 1){
                cell.separatorLabel.isHidden = true
            }

        }else{
            cell.viewResumeBtn.isHidden = true
            cell.labelRightConstant.constant = 5
            dict = secondDetailsArray[indexPath.row]
            
            if indexPath.row == occupationPosition && resumeUrl != nil{
                cell.viewResumeBtn.addTarget(self, action: #selector(self.viewResume), for: .touchUpInside)
                cell.viewResumeBtn.isHidden = false
                cell.labelRightConstant.constant = 85
                cell.viewResumeBtn.layer.cornerRadius = 4
                cell.viewResumeBtn.layer.borderWidth = 1
                cell.viewResumeBtn.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            if indexPath.row == (secondDetailsArray.count - 1 ) {
                cell.separatorLabel.isHidden = true
            }
        }
        cell.titelLabel.text = (dict["title"] as! String)
        cell.contentImageView.image = UIImage.init(named: dict["image"] as! String)
      
        return cell
    }
    
    //MARK:- Service Helper Methods
    func callAPIToGetCapturedUsers(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["profile_user_id"] = self.profileUserID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kGetFriendsProfileDetails) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.resetProfileDetails(dict: responseDict.validatedValue(kData, expected: [:] as AnyObject) as! Dictionary<String, AnyObject>)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func resetProfileDetails(dict: Dictionary<String, AnyObject>){
    
        profileDict = dict
        
        profileImageList = dict.validatedValue("images", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]
        
//        if (dict.validatedValue("is_friend", expected: 0 as AnyObject) as! Bool) {
//            self.friendRquestStstus = .Friend
//        }else{
//            self.friendRquestStstus = .Unfriend
//        }
        
        
        if (dict.validatedValue("image", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject).length != 0{
            profileImageList.append(["name":["thumb":(dict.validatedValue("image", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String] as AnyObject])
        }
        
        self.profileNameLabel.text = "\(dict.validatedValue("first_name", expected: "" as AnyObject)) \(dict.validatedValue("last_name", expected: "" as AnyObject))"
        
        var count:Int = 0
        if dict.validatedValue("email", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":dict.validatedValue("email", expected: "" as AnyObject), "image":"email" as AnyObject])
            count += 1
            emailIDIndex = firstDetailsArray.count - 1
            
        }
        
        if dict.validatedValue("phone", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":dict.validatedValue("phone", expected: "" as AnyObject), "image":"phone" as AnyObject])
            count += 1
            mobileNumberIndex = firstDetailsArray.count - 1

        }
     
        if dict.validatedValue("resume", expected: "" as AnyObject).length != 0 {
            resumeUrl = URL.init(string: dict.validatedValue("resume", expected: "" as AnyObject) as! String)
        }
        
        let cityAddress = dict.validatedValue("city", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
        let stateAddress = dict.validatedValue("state", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>

        if cityAddress.validatedValue("name", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":"Currently Lives in: \(stateAddress.validatedValue("name", expected: "" as AnyObject)), \(cityAddress.validatedValue("name", expected: "" as AnyObject))" as AnyObject, "image":"loaction" as AnyObject])
            count += 1
        }
        
        let fromCityAddress = dict.validatedValue("city", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
        let fromStateAddress = dict.validatedValue("state", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
        
        if fromCityAddress.validatedValue("name", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":"From: \(fromStateAddress.validatedValue("name", expected: "" as AnyObject)), \(fromCityAddress.validatedValue("name", expected: "" as AnyObject))" as AnyObject, "image":"loaction" as AnyObject])
            count += 1
        }
        
        if dict.validatedValue("fb_link", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":dict.validatedValue("fb_link", expected: "" as AnyObject), "image":"facebook" as AnyObject])
            count += 1
        }
        
        if dict.validatedValue("insta_link", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":dict.validatedValue("insta_link", expected: "" as AnyObject), "image":"instagram" as AnyObject])
            count += 1
        }
        
        if dict.validatedValue("linked_in_link", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":dict.validatedValue("linked_in_link", expected: "" as AnyObject), "image":"linkedin" as AnyObject])
            count += 1
        }
        
        if dict.validatedValue("twit_link", expected: "" as AnyObject).length != 0 {
            firstDetailsArray.append(["title":dict.validatedValue("twit_link", expected: "" as AnyObject), "image":"twitter" as AnyObject])
            count += 1
        }
        
        if count == 0 {
            self.firstContainerHeightConstant.constant = 0
        }else{
            self.firstContainerHeightConstant.constant = CGFloat(44 * count)
        }
        
        count = 0
        
        if dict.validatedValue("college", expected: "" as AnyObject).length != 0 {
            secondDetailsArray.append(["title":dict.validatedValue("college", expected: "" as AnyObject), "image":"study" as AnyObject])
            count += 1
        }
        
        if dict.validatedValue("education", expected: "" as AnyObject).length != 0 {
            secondDetailsArray.append(["title":dict.validatedValue("education", expected: "" as AnyObject), "image":"institute" as AnyObject])
            count += 1
        }
        
        if dict.validatedValue("high_school", expected: "" as AnyObject).length != 0 {
            secondDetailsArray.append(["title":dict.validatedValue("high_school", expected: "" as AnyObject), "image":"study" as AnyObject])
            count += 1

        }
        
        if dict.validatedValue("likes", expected: "" as AnyObject).length != 0 {
            secondDetailsArray.append(["title":dict.validatedValue("likes", expected: "" as AnyObject), "image":"share" as AnyObject])
            count += 1

        }
        
       
        
        if dict.validatedValue("occupation", expected: "" as AnyObject).length != 0 {
            occupationPosition = secondDetailsArray.count
            secondDetailsArray.append(["title":dict.validatedValue("occupation", expected: "" as AnyObject), "image":"desination" as AnyObject])
            count += 1

        }
        
        if dict.validatedValue("work_website", expected: "" as AnyObject).length != 0 {
            secondDetailsArray.append(["title":dict.validatedValue("work_website", expected: "" as AnyObject), "image":"desination" as AnyObject])
            count += 1
        }
        
        if (dict.validatedValue("military", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject).length != 0 {
            occupationPosition = secondDetailsArray.count
            secondDetailsArray.append(["title":(dict.validatedValue("military", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject), "image":"usaf" as AnyObject])
            count += 1
            
        }
        
        if (dict.validatedValue("political", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject).length != 0 {
            occupationPosition = secondDetailsArray.count
            secondDetailsArray.append(["title":(dict.validatedValue("political", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject), "image":"flat" as AnyObject])
            count += 1
        }
        
        if (dict.validatedValue("religion", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject).length != 0 {
            occupationPosition = secondDetailsArray.count
            secondDetailsArray.append(["title":(dict.validatedValue("religion", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject), "image":"church" as AnyObject])
            count += 1
        }
        
        if (dict.validatedValue("relationship", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject).length != 0 {
            occupationPosition = secondDetailsArray.count
            secondDetailsArray.append(["title":(dict.validatedValue("relationship", expected: [:] as AnyObject) as! Dictionary<String,AnyObject>).validatedValue("name", expected: "" as AnyObject), "image":"status" as AnyObject])
            count += 1
        }
       
        
        requestStatus = dict.validatedValue("req_status", expected: "" as AnyObject) as! String
        self.resetFriendStatusBtn()
        if count == 0 {
            self.secondContainerHeightConstant.constant = 0
        }else{
            self.secondContainerHeightConstant.constant = CGFloat(44 * count)
        }
        
        let mutualFriendDict = dict.validatedValue("mutual_friends", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
        
        if mutualFriendDict.count != 0{
            
            if (mutualFriendDict.validatedValue("last_page", expected: 0 as AnyObject) as! Int) == 1{
                self.viewMoreBtn.isHidden = true;
            }
            
            for dic in ((mutualFriendDict.validatedValue("data", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]) ) {
                let obj = FriendInfo()
                obj.fUserFirstName = dic.validatedValue("first_name", expected: "" as AnyObject) as! String
                obj.fFriendrequestID = dic.validatedValue("friend_request_id", expected: "" as AnyObject) as! String
                obj.fUserID = dic.validatedValue("id", expected: "" as AnyObject) as! String
                obj.fFriendUserID = dic.validatedValue("friend_user_id", expected: "" as AnyObject) as! String
                obj.fUserImage = "\(dic.validatedValue("image_path", expected: "" as AnyObject) as! String)/\(dic.validatedValue("image", expected: "" as AnyObject) as! String)"
                obj.fLastName = dic.validatedValue("last_name", expected: "" as AnyObject) as! String
                mutualFriend.append(obj)
                
            }
            countMutualFriendlabel.text = "\(mutualFriend.count) Mutual Friends"
        }else{
            countMutualFriendlabel.text = "No Mutual Friend"
        }
    
        let familyMemberDict = dict.validatedValue("family", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
        
        if familyMemberDict.count != 0{
            
            if (familyMemberDict.validatedValue("last_page", expected: 0 as AnyObject) as! Int) == 1{
                self.familyMoreBtn.isHidden = true;
            }
            
            for dic in ((familyMemberDict.validatedValue("data", expected: [] as AnyObject) as! [Dictionary<String, AnyObject>]) ) {
                let userInfo = dic.validatedValue("user_info", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>
                let obj = FriendInfo()
                obj.fUserFirstName = userInfo.validatedValue("first_name", expected: "" as AnyObject) as! String
                
                obj.fUserID = userInfo.validatedValue("id", expected: "" as AnyObject) as! String
                obj.fFriendUserID = userInfo.validatedValue("id", expected: "" as AnyObject) as! String
                obj.fUserImage = (userInfo.validatedValue("image", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("thumb", expected: "" as AnyObject) as! String
                familyFriends.append(obj)
            }
            familyCountLabel.text = "\(familyFriends.count) Family Members"
        }
        
        if mutualFriend.count == 0{
            collectionViewHeightConstant.constant = 0
            countMutualFriendlabel.text = ""
        }
        
        if familyFriends.count == 0{
            familyContainerViewHeightConstant.constant = 0
            familyCountLabel.text = ""
        }
        
        DispatchQueue.main.async {
            
            if (self.familyContainerViewHeightConstant.constant + self.firstContainerHeightConstant.constant + self.secondContainerHeightConstant.constant) < 300{
                self.profileTableView.isScrollEnabled = false
            }
            
            if self.resumeUrl != nil{
                let urlRequest = URLRequest(url: self.resumeUrl)
                self.myWebView?.loadRequest(urlRequest)
            }
            
            self.friendCollectionView.reloadData()
            self.firstContentTableView.reloadData()
            self.secondContentTableView.reloadData()
            self.carausalCollectionView.reloadData()
            self.familyCollectionView.reloadData()
            if self.profileImageList.count > 2{
                let indexPath = IndexPath.init(row: 2, section: 0)
                self.carausalCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
            
            if self.profileImageList.count == 0{
                self.placeHolderImageview.isHidden = false
            }
        }
    }
    
    func callAPIToSendFriendRequest(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["receiver_user_id"] = profileDict.validatedValue("id", expected:"" as AnyObject ) as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kSendFriendRequestAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    self.friendRquestStstus = FriendRequestStatus.FriendRequestSend
                    self.requestStatus = "REQ_SENT"
                    self.resetFriendStatusBtn()
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "We have send \(self.profileDict.validatedValue("first_name", expected: "" as AnyObject)) a connection request we will notify you as soon as we get a response."
                    objVC.isFromRequestSend = true
                    objVC.modalPresentationStyle = .overFullScreen
                    self.present(objVC, animated: true, completion: nil)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func callAPIToCancelFriendRequest(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["friend_user_id"] = self.profileUserID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kCancelFriendRequest) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    self.friendRquestStstus = FriendRequestStatus.Unfriend
                    self.requestStatus = "New User"
                    self.resetFriendStatusBtn()
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "Friend request cancel successfully."
                    objVC.isFromRequestSend = true
                    objVC.titleString = "Request Cancel"
                    objVC.modalPresentationStyle = .overFullScreen
                    self.present(objVC, animated: true, completion: nil)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func callAPIToUnFrinedUser(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["friend_user_id"] = self.profileUserID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kUnFriendUserAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    self.friendRquestStstus = FriendRequestStatus.Unfriend
                    self.requestStatus = "new user"
                    self.resetFriendStatusBtn()
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = responseDict.validatedValue("message", expected: "" as AnyObject) as! String
                    objVC.isFromRequestSend = true
                    objVC.modalPresentationStyle = .overFullScreen
                    self.present(objVC, animated: true, completion: nil)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    func callAPIToAcceptFriendRequest(action : String){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["another_user_id"] = profileDict.validatedValue("id", expected:"" as AnyObject ) as AnyObject
        dictParams["action"] = action as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kAcceptApproveFriendRequest) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                    objVC.messageString = "Request \(action == "A" ?"accept":"reject") successfully."
                    objVC.isFromRequestSend = true
                    objVC.titleString = "Success"
                    objVC.modalPresentationStyle = .overFullScreen
                    self.present(objVC, animated: true, completion: nil)
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
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
