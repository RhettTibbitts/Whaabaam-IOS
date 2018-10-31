//
//  ChatListViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 31/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QMChatServiceDelegate, QMChatConnectionDelegate, QMAuthServiceDelegate, UITextFieldDelegate {

    //Outlet
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewRightConstant: NSLayoutConstraint!
    @IBOutlet weak var searchViewLeftConstant: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    
    //instance variable
    private var didEnterBackgroundDate: NSDate?
    private var observer: NSObjectProtocol?
    var filterName: String = ""
    var chatList = [QBChatDialog]()
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APPDELEGATE.getAllUsers()
        
        self.initialMethods()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getDialogs()
    }
    

    //MARK:- Helper Methods
    func initialMethods(){
        self.topView.setShadow(radius: 0)
        self.searchView.layer.cornerRadius = 6
        searchViewLeftConstant.constant = -(WINDOW_WIDTH + searchViewLeftConstant.constant)
        searchViewRightConstant.constant = (WINDOW_WIDTH + searchViewRightConstant.constant)
        self.searchTextField.delegate = self
        
        //chat dialog setup
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().authService.add(self)
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            
            if !QBChat.instance.isConnected {
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackgroundNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        if (!(QBChat.instance.isConnected)) {
            APPDELEGATE.connectUserWithChat()
        }else{
            APPDELEGATE.connectUserWithChat()
        }
    }
    
    //reload chatList
    func reloadChatList(){
        
        if filterName.count == 0 {
            chatList = ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false)
        }else{
            chatList.removeAll()
           
            for dial in ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false){
                var  stri = ""
                stri = (dial.name?.lowercased())!
                
                if stri.lowercased().contains(filterName) {
                    chatList.append(dial)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        
    }
    
    //method to fetch all chat list
    // MARK: - DataSource Action
    func getDialogs() {
        showHud()
        if let lastActivityDate = ServicesManager.instance().lastActivityDate {
            
            ServicesManager.instance().chatService.fetchDialogsUpdated(from: lastActivityDate as Date, andPageLimit: kDialogsPageLimit, iterationBlock: { (response, dialogObjects, dialogsUsersIDs, stop) -> Void in
                    self.reloadChatList()
            }, completionBlock: { (response) -> Void in
                hideHud()
                if (response.isSuccess) {
                    ServicesManager.instance().lastActivityDate = NSDate()
                    self.reloadChatList()
                }
            })
        }
        else {
            ServicesManager.instance().chatService.allDialogs(withPageLimit: kDialogsPageLimit, extendedRequest: nil, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDS: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                self.reloadChatList()
            }, completion: { (response: QBResponse?) -> Void in
                hideHud()
                guard response != nil && response!.isSuccess else {
                    return
                }
                ServicesManager.instance().lastActivityDate = NSDate()
                 self.reloadChatList()
            })
        }
        
    }
    
    // MARK: - DataSource
    func dialogs() -> [QBChatDialog]? {
        
        // Returns dialogs sorted by updatedAt date.
        
        if filterName.count == 0 {
            return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false)

        }else{
            
            var tempList = [QBChatDialog]()
            for dial in ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false){
                var  stri = ""
                stri = (dial.name?.lowercased())!

                if stri.lowercased().contains(filterName) {
                    tempList.append(dial)
                }
            }
            return tempList
        }
    }
    
    //MARK: - UITextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        filterName = (textField.text?.trimmingCharacters(in: .whitespaces))!
        self.reloadChatList()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .search {
            view.endEditing(true)
        }
        return true
    }
    
    
    //MARK: - Selector Methods
    @objc func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }
    
    //MARK: - IBAction Methods
    @IBAction func myConnectionBtnAction(_ sender: Any) {
        
        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "ConnectionViewController") as! ConnectionViewController
        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
        
    }
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            searchViewLeftConstant.constant = 8
            searchViewRightConstant.constant = 8
        }else{
            searchViewLeftConstant.constant = -(WINDOW_WIDTH + searchViewLeftConstant.constant)
            searchViewRightConstant.constant = (WINDOW_WIDTH + searchViewRightConstant.constant)
            filterName = ""
            self.reloadChatList()
        }
        
        
        UIView.animate(withDuration: 0.30,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            // ....
        })
        
    }
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if chatList.count == 0{
            self.blankView.isHidden = false
        }else{
            self.blankView.isHidden = true
        }
        return chatList.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 72
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell : FeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.layer.frame.size.height / 2;
        
        let chatDialog = chatList[indexPath.row]
        
        let cellModel = QBChatDialogInfo(dialog: chatDialog)
        
        cell.dayTimeLabel.text = chatDialog.lastMessageText
        cell.titleLabel.text = cellModel.textLabelText
        cell.profileImageView.sd_setImage(with: URL.init(string: cellModel.userImage), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
        
        if cellModel.unreadMessagesCounterLabelText?.count == 0 || cellModel.unreadMessagesCounterLabelText == nil{
            cell.messageBtn.isHidden = true
        }else{
            cell.messageBtn.isHidden = false
            cell.messageBtn.setTitle(cellModel.unreadMessagesCounterLabelText, for: .normal)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.callAPIToCheckUserIsFrined(dialog: self.dialogs()![indexPath.row])
//        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
//        objVC.dialog = self.dialogs()![indexPath.row]
//        APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
        
    }
    
    //MARK:- Service Helper Methods
    func callAPIToCheckUserIsFrined(dialog : QBChatDialog){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["quickblox_id"] = dialog.recipientID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kCheckContactExistInFriend) { (response, error) in
            
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                    objVC.dialog = dialog
                    if (responseDict.validatedValue("friend", expected: "" as AnyObject) as! String) != "NO"{
                        objVC.isFriend = true
                    }else{
                        objVC.isFriend = false
                    }
                    APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
                }else{
                    let objVC = mainStoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                    objVC.dialog = dialog
                    objVC.isFriend = false
                    APPDELEGATE.navigationController.pushViewController(objVC, animated: true)
                    
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


