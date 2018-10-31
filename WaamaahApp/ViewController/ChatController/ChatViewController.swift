//
//  ChatViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 30/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class ChatViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, QMChatServiceDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate, QMChatCellDelegate, QMDeferredQueueManagerDelegate, QMPlaceHolderTextViewPasteDelegate {
    
    func placeHolderTextView(_ textView: QMPlaceHolderTextView, shouldPasteWithSender sender: Any) -> Bool {
        return true
        
    }
    
    func chatCellDidTapAvatar(_ cell: QMChatCell!) {
        
    }
    
    func chatCellDidTapContainer(_ cell: QMChatCell!) {
        
    }
    

    //outlet
    @IBOutlet weak var connectionDescriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomViewConstant: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    
    //instance variable
    var messageList = [ChatInfo]()
    let maxCharactersNumber = 1024 // 0 - unlimited
    var failedDownloads: Set<String> = []
    var dialog: QBChatDialog!
    var willResignActiveBlock: AnyObject?
    var attachmentCellsMap: NSMapTable<AnyObject, AnyObject>!
    var detailedCells: Set<String> = []
    var typingTimer: Timer?
    var unreadMessages: [QBChatMessage]?
    var senderID: UInt!
    var senderDisplayName: String!
    var chatDataSource = QMChatDataSource()
    
    var messageList1 = [QBChatMessage]()
    
    //MARK: - UIViewLife Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
        self.setDummydata()
        self.setupUserForChat()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.queueManager().add(self)
        
        self.willResignActiveBlock = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            
           // self?.fireSendStopTypingIfNecessary()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Saving current dialog ID.
        ServicesManager.instance().currentDialogID = self.dialog.id!
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let willResignActive = self.willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        
        // Resetting current dialog ID.
        ServicesManager.instance().currentDialogID = ""
        
        // clearing typing status blocks
        self.dialog.clearTypingStatusBlocks()
        
        self.queueManager().remove(self)
    }
    
    //MARK: - Helper Methods
    func initialMethods(){
        
        profileImageView.layer.cornerRadius = 18
        topView.setShadow(radius: 0)
        
        //keayboard hide and show notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //setup user for chat
    func setupUserForChat(){
        if let currentUser:QBUUser = ServicesManager.instance().currentUser {
            self.senderID = currentUser.id
            //self.senderDisplayName = currentUser.login!
            
            ServicesManager.instance().chatService.addDelegate(self)
            ServicesManager.instance().chatService.chatAttachmentService.addDelegate(self)
            
            self.updateTitle()
            
            //self.inputToolbar?.contentView?.backgroundColor = UIColor.white
           // self.inputToolbar?.contentView?.textView?.placeHolder = "SA_STR_MESSAGE_PLACEHOLDER".localized
            
            self.attachmentCellsMap = NSMapTable(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
            
            if self.dialog.type == QBChatDialogType.private {
                
                self.dialog.onUserIsTyping = {
                    (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser.id == userID {
                        return
                    }
                    
//                    self?.title = "SA_STR_TYPING".localized
                }
                
                self.dialog.onUserStoppedTyping = {
                    [weak self] (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser.id == userID {
                        return
                    }
                    self?.updateTitle()
                }
            }
            
            // Retrieving messages
            let messagesCount = self.storedMessages()?.count
            if (messagesCount == 0) {
               // self.startSpinProgress()
            }
            else if (self.chatDataSource.messagesCount() == 0) {
                self.chatDataSource.add(self.storedMessages()!)
            }
            
            self.loadMessages()
            
           // self.enableTextCheckingTypes = NSTextCheckingAllTypes
        }
    }
    
    //set title text of user
    func updateTitle() {
        if self.dialog.type != QBChatDialogType.private {
            
            self.titleLabel.text = self.dialog.name
        }
        else {
            
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(self.dialog!.recipientID)) {
                self.titleLabel.text = recipient.login
            }
        }
    }
    
    func queueManager() -> QMDeferredQueueManager {
        return ServicesManager.instance().chatService.deferredQueueManager
    }
    
    //get all messages count
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messages(withDialogID: self.dialog.id!)
    }
    
    //fetch all messages
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
        guard let currentDialogID = self.dialog.id else {
            logInfo(message:"Current chat dialog is nil")
            return
        }
        showHud()
        ServicesManager.instance().chatService.messages(withChatDialogID: currentDialogID, completion: {
            [weak self] (response, messages) -> Void in
            hideHud()
            
            guard let strongSelf = self else { return }
            
            guard response.error == nil else {
               // SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                return
            }
            strongSelf.messageList1 = messages!
            if messages?.count ?? 0 > 0 {
//                if !(self?.progressView?.isHidden)! {
//                    self?.stopSpinProgress()
//                }
                strongSelf.chatDataSource.add(messages)
            }
            strongSelf.chatTableView.reloadData()
           // SVProgressHUD.dismiss()
        })
    }
    
    func setDummydata(){
        
        let obj1 = ChatInfo()
        obj1.messageStr = "Hi, could you remind me or the problem?"
        obj1.timeStr = "2:43 PM"
        obj1.isSender = false
        messageList.append(obj1)
        
        let obj2 = ChatInfo()
        obj2.messageStr = "Oh sure. I'll send you in the mail. Do not forget to check."
        obj2.timeStr = "2:48 PM"
        obj2.isSender = true
        messageList.append(obj2)
        
        let obj3 = ChatInfo()
        obj3.messageStr = "Hi, could you remind me or the problem?"
        obj3.timeStr = "2:33 PM"
        obj3.isSender = false
        messageList.append(obj3)
        
        let obj4 = ChatInfo()
        obj4.messageStr = "Good music i love it."
        obj4.timeStr = "3:43 PM"
        obj4.isSender = true
        messageList.append(obj4)
        
        self.chatTableView.reloadData()
        self.scrollAtLastInTableView()
        
    }
    
    //scroll in last tableview
    func scrollAtLastInTableView(){
        
        if self.messageList1.count == 0 {
            return
        }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageList1.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
        }
        
    }
    
    //MARK: - Keayboard hide show methods
    @objc func keyboardWillShow(notification: Notification) {
        
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn],
                       animations: {
                        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
                        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        let keyboardHeight = keyboardRectangle.height
                        self.bottomViewConstant.constant = -keyboardHeight;
                        self.view.layoutIfNeeded()
                        self.scrollAtLastInTableView()
        }, completion: nil)
        

    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn],
                       animations: {
                        
                        self.bottomViewConstant.constant = 0;
                        self.view.layoutIfNeeded()
                        self.scrollAtLastInTableView()
        }, completion: nil)
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
    
    //MARK: - IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnAction(_ sender: Any) {
        
        if ((messageTextField.text?.trimmingCharacters(in: .whitespaces).count) != nil) {
            let tempObj = ChatInfo()
            tempObj.messageStr = messageTextField.text!
            tempObj.timeStr = Date().getTimeStringToDate()
            tempObj.isSender = true
            messageList.append(tempObj)
           // chatTableView.reloadData()
           // self.scrollAtLastInTableView()
            self.messageTextField.text = ""
           // self.view.endEditing(true)
            
            let message = QBChatMessage()
            message.text = messageTextField.text!
            message.senderID = self.senderID
            message.deliveredIDs = [(NSNumber(value: self.senderID))]
            message.readIDs = [(NSNumber(value: self.senderID))]
            message.markable = true
            message.dateSent = Date()
            self.sendMessage(message: message)
            
        }
        
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        ServicesManager.instance().chatService.send(message, toDialogID: self.dialog.id!, saveToHistory: true, saveToStorage: true) { (error) ->
            Void in
            
            if error != nil {
                self.loadMessages()
                QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle: error?.localizedDescription, type: QMMessageNotificationType.warning)
            }
        }
        
    }
    
    //MARK:- UITableview Delegate And DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messageList1.count
    }
    
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
//        return 60
//    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let obj = messageList1[indexPath.row]
        
        if  obj.senderID == ServicesManager.instance().currentUser.id {
            let cell : SenderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SenderTableViewCell") as! SenderTableViewCell
            cell.messageLabel.text = obj.text
            cell.timeLabel.text = obj.dateSent?.getDateWithDDMMMYYYYHHMMAFormat()
            return cell
        }else{
            let cell : RecieverTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RecieverTableViewCell") as! RecieverTableViewCell
            cell.messageLabel.text = obj.text
            cell.timeLabel.text = obj.dateSent?.getDateWithDDMMMYYYYHHMMAFormat()
            return cell
        }
    }
    
    
    
    //MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
