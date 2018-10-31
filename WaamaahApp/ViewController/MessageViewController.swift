//
//  MessageViewController.swift
//  WaamaahApp
//
//  Created by Ashish on 31/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import CoreTelephony
import SafariServices

var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    
    return Static.instance
}

extension String {
    var length: Int {
        return (self as NSString).length
    }
}

class MessageViewController: QMChatViewController, QMChatServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate, QMChatCellDelegate, QMDeferredQueueManagerDelegate, QMPlaceHolderTextViewPasteDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var headerView: UIView!
    let maxCharactersNumber = 1024 // 0 - unlimited
    
    var failedDownloads: Set<String> = []
    var dialog: QBChatDialog!
    var willResignActiveBlock: AnyObject?
    var attachmentCellsMap: NSMapTable<AnyObject, AnyObject>!
    var detailedCells: Set<String> = []
    var userNameLabel: UILabel!
    var profileImageView: UIImageView!
    var isFirstTime:Bool!
    var typingTimer: Timer?
    var profileDict = Dictionary<String, AnyObject>()
    var isFriend = true
    var menuView:UIView!
    var userID = ""
    @IBOutlet weak var topView: UIView!
    lazy var imagePickerViewController : UIImagePickerController = {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        
        return imagePickerViewController
    }()
    
    var unreadMessages: [QBChatMessage]?
    
    //MARK: - UIView Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerViewSetup()
        self.initialMethods()
       //self.userNameLabel.text = "dffd"
        self.view.backgroundColor = UIColor.init(red: (243/255.0), green: (243/255.0), blue: (243/255.0), alpha: 1.0)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.queueManager().add(self)
        
        self.willResignActiveBlock = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            
            self?.fireSendStopTypingIfNecessary()
        }
        
        APPDELEGATE.connectUserWithChat()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Helper methods
    
    func headerViewSetup(){
        let viewHeight = 84
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: Int(WINDOW_WIDTH), height: viewHeight))
        myView.backgroundColor = UIColor.white
        
        let myView1 = UIView(frame: CGRect(x: 0, y: 0, width: WINDOW_WIDTH, height: 20))
        myView1.backgroundColor = UIColor.black
        myView.addSubview(myView1)
        
        let backBtn = UIButton.init(frame: CGRect(x: 0, y: viewHeight - 50, width: 40, height: 40))
        backBtn.setImage(#imageLiteral(resourceName: "back_button"), for: .normal)
        backBtn.addTarget(self, action: #selector(self.backBtnAction(sender:)), for: .touchUpInside)
        myView.addSubview(backBtn)
        
        let menuBtn = UIButton.init(frame: CGRect(x: Int(WINDOW_WIDTH - 50), y: viewHeight - 50, width: 40, height: 40))
        menuBtn.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(self.menuBtnAction(sender:)), for: .touchUpInside)
        myView.addSubview(menuBtn)
        profileImageView = UIImageView.init(frame: CGRect(x: 50, y: viewHeight - 50, width: 40, height: 40))
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        myView.addSubview(profileImageView!)
        profileImageView.image = #imageLiteral(resourceName: "placeholder")
        userNameLabel = UILabel.init(frame: CGRect(x: 100, y: viewHeight - 45, width: (Int(WINDOW_WIDTH - 110)), height: 30))
        userNameLabel.text = self.dialog.name
        
        myView.addSubview(userNameLabel!)
        self.view.addSubview(myView)
        myView.setShadow(radius: 0)
        
        self.menuView = UIView(frame: CGRect(x: Int(WINDOW_WIDTH - 130), y: Int(viewHeight - 50), width: 85, height: 80))
        menuView.backgroundColor = UIColor.white
        menuView.layer.setShadow(radius: 2)
        
        let reportBtn = UIButton.init(frame: CGRect(x: 10, y: 0, width: 70, height: 40))
        reportBtn.setTitle("Report", for: .normal)
        reportBtn.contentHorizontalAlignment = .left
        reportBtn.titleLabel?.font = UIFont.init(name: "Poppins", size: 14)
        reportBtn.setTitleColor(UIColor.black, for: .normal)
        reportBtn.addTarget(self, action: #selector(self.reportBtnAction(sender:)), for: .touchUpInside)
        menuView.addSubview(reportBtn)
        
        let blockBtn = UIButton.init(frame: CGRect(x: 10, y: 40, width: 70, height: 40))
        blockBtn.titleLabel?.font = UIFont.init(name: "Poppins", size: 14)
        blockBtn.contentHorizontalAlignment = .left
        blockBtn.setTitle("Block", for: .normal)
        blockBtn.setTitleColor(UIColor.black, for: .normal)
        blockBtn.addTarget(self, action: #selector(self.unFriendBtnAction(sender:)), for: .touchUpInside)
        menuView.addSubview(blockBtn)
        
        self.view.addSubview(menuView)
        
        self.menuView.isHidden = true
        
        QBRequest.user(withID: UInt(self.dialog.recipientID), successBlock: { (response, user) in
            self.userID = user.login!
            if user.customData?.count != 0 && user.customData != nil{
                self.profileImageView.sd_setImage(with: URL.init(string: user.customData!), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .continueInBackground, completed: nil)
            }
        }) { (error) in
            logInfo(message: "Error ")
        }
    }
    
    func initialMethods(){
        
        
        // top layout inset for collectionView
        self.topContentAdditionalInset = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
        
        view.backgroundColor = UIColor.white
        self.collectionView?.backgroundColor = .clear
        
        if let currentUser:QBUUser = ServicesManager.instance().currentUser {
            self.senderID = currentUser.id
            self.senderDisplayName = currentUser.email!
            
            ServicesManager.instance().chatService.addDelegate(self)
            ServicesManager.instance().chatService.chatAttachmentService.addDelegate(self)
            
            self.updateTitle()
            
            self.inputToolbar?.contentView?.backgroundColor = UIColor.white
            self.inputToolbar?.contentView?.textView?.placeHolder = "Type a message here...".localized
            
            self.attachmentCellsMap = NSMapTable(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
            
            if self.dialog.type == QBChatDialogType.private {
                
                self.dialog.onUserIsTyping = {
                    [weak self] (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser.id == userID {
                        return
                    }
                    
                    self?.title = "SA_STR_TYPING".localized
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
                self.startSpinProgress()
            }
            else if (self.chatDataSource.messagesCount() == 0) {
                self.chatDataSource.add(self.storedMessages()!)
            }
            
            self.loadMessages()
            self.enableTextCheckingTypes = NSTextCheckingAllTypes
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.delegate = self // This is not required
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.menuView.isHidden = true
    }
    
    func createNewDailog(){
        
        let chatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.private)
        chatDialog.name = ""
        chatDialog.occupantIDs = [55, 678, 22]
        
        QBRequest.createDialog(chatDialog, successBlock: { (response: QBResponse?, createdDialog : QBChatDialog?) -> Void in
            
        }) { (responce : QBResponse!) -> Void in
            
        }
        
    }
    
    // MARK: Update
    func updateTitle() {
        
        if self.dialog.type != QBChatDialogType.private {
            self.userNameLabel.text = self.dialog.name
            self.title = self.dialog.name
        }
        else {
            
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(self.dialog!.recipientID)) {
                self.userNameLabel.text = recipient.login
                self.title = recipient.login
            }
        }
    }
    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messages(withDialogID: self.dialog.id!)
    }
    
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
        guard let currentDialogID = self.dialog.id else {
            logInfo(message:"Current chat dialog is nil")
            return
        }
        
        ServicesManager.instance().chatService.messages(withChatDialogID: currentDialogID, completion: {
            [weak self] (response, messages) -> Void in
            
            guard let strongSelf = self else {
                self?.stopSpinProgress()
                return
                
            }
            
            guard response.error == nil else {
                self?.stopSpinProgress()
               // SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                return
            }
            
            if messages?.count ?? 0 > 0 {
                if !(self?.progressView?.isHidden)! {
                    self?.stopSpinProgress()
                }
                strongSelf.chatDataSource.add(messages)
            }
            self?.stopSpinProgress()
            
           // SVProgressHUD.dismiss()
        })
    }
    
    func sendReadStatusForMessage(message: QBChatMessage) {
        
        guard QBSession.current.currentUser != nil else {
            return
        }
        guard message.senderID != QBSession.current.currentUser?.id else {
            return
        }
        
        if self.messageShouldBeRead(message: message) {
            ServicesManager.instance().chatService.read(message, completion: { (error) -> Void in
                
                guard error == nil else {
                    return
                }
                
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                    UIApplication.shared.applicationIconBadgeNumber = badgeNumber - 1
                }
            })
        }
    }
    
    func messageShouldBeRead(message: QBChatMessage) -> Bool {
        
        let currentUserID = NSNumber(value: QBSession.current.currentUser!.id as UInt)
        
        return !message.isDateDividerMessage
            && message.senderID != self.senderID
            && !(message.readIDs?.contains(currentUserID))!
    }
    
    func readMessages(messages: [QBChatMessage]) {
        
        if QBChat.instance.isConnected {
            
            ServicesManager.instance().chatService.read(messages, forDialogID: self.dialog.id!, completion: nil)
        }
        else {
            
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.id!)
        }
    }
    
    //MARK: - Selector Methods
    @objc func backBtnAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func menuBtnAction(sender: UIButton){
        self.menuView.isHidden = !self.menuView.isHidden
    }
    
    @objc func reportBtnAction(sender: UIButton){

        let alertController = UIAlertController(title: "Alert", message: "Report this contact to Whaabaam?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "REPORT", style: .default) { (action:UIAlertAction!) in
            self.callAPIToReportUser()
        }
        alertController.addAction(OKAction)
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel) { (action:UIAlertAction!) in
            self.menuView.isHidden = true
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    @objc func unFriendBtnAction(sender: UIButton){
        
        
        let alertController = UIAlertController(title: "Alert", message: "Block \(self.dialog.name ?? "")? You will no longer be able to send messages to this user.", preferredStyle: .alert)
        
        
        let OKAction = UIAlertAction(title: "BLOCK", style: .default) { (action:UIAlertAction!) in
            self.callAPIToUnFrinedUser()
        }
        alertController.addAction(OKAction)
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel) { (action:UIAlertAction!) in
            self.menuView.isHidden = true
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)

    }
    
    // MARK: Actions
    override func didPickAttachmentImage(_ image: UIImage) {
        
        if self.isFriend == false{
            let username = NSString(format:"%@",dialog.name!) as String
            showAlert(title: "Warning", message: "Please make sure, \(username) is your friend.", controller: self)
            return
        }
        
        let message = QBChatMessage()
        message.senderID = self.senderID
        message.dialogID = self.dialog.id
        message.dateSent = Date()
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            guard let strongSelf = self else { return }
            
            var newImage : UIImage! = image
            if strongSelf.imagePickerViewController.sourceType == UIImagePickerControllerSourceType.camera {
                newImage = newImage.fixOrientation()
            }
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            
            UIGraphicsBeginImageContext(newSize)
            
            newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                self?.chatDataSource.add(message)
                // sendAttachmentMessage method always firstly adds message to memory storage
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self!.dialog, withAttachmentImage: resizedImage!, completion: {
                    [weak self] (error) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    self?.chatDataSource.delete(message)
                })
            })
        }
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: UInt, senderDisplayName: String, date: Date) {
        
        if self.isFriend == false{
            let username = NSString(format:"%@",dialog.name!) as String
            showAlert(title: "Warning", message: "Please make sure, \(username) is your friend.", controller: self)
            return
        }
        
//        if !self.queueManager().shouldSendMessagesInDialog(withID: self.dialog.id!) {
//            return
//        }
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text
        message.senderID = self.senderID
        message.deliveredIDs = [(NSNumber(value: self.senderID))]
        message.readIDs = [(NSNumber(value: self.senderID))]
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message: message)
    }
    
    override func didPressSend(_ button: UIButton, withTextAttachments textAttachments: [Any], senderId: UInt, senderDisplayName: String, date: Date) {
        
        if let attachment = textAttachments.first as? NSTextAttachment {
            
            if (attachment.image != nil) {
                let message = QBChatMessage()
                message.senderID = self.senderID
                message.dialogID = self.dialog.id
                message.dateSent = Date()
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self.dialog, withAttachmentImage: attachment.image!, completion: {
                    [weak self] (error: Error?) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    // perform local attachment message deleting if error
                    ServicesManager.instance().chatService.deleteMessageLocally(message)
                    
                    self?.chatDataSource.delete(message)
                    
                })
                
                self.finishSendingMessage(animated: true)
            }
        }
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        ServicesManager.instance().chatService.send(message, toDialogID: self.dialog.id!, saveToHistory: true, saveToStorage: true) { (error) ->
            Void in
           
            if error != nil {
                self.callAPIToSendErrorMessage(message: "Error\(error?.localizedDescription ?? "")")
//                showAlert(title: "Error", message: "Something went wrong!", controller: self)
            }
        }
        
        self.finishSendingMessage(animated: true)
    }
    
    // MARK: Helper
    func canMakeACall() -> Bool {
        
        var canMakeACall = false
        
        if (UIApplication.shared.canOpenURL(URL.init(string: "tel://")!)) {
            
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier = networkInfo.subscriberCellularProvider
            if carrier == nil {
                return false
            }
            let mnc = carrier?.mobileNetworkCode
            if mnc?.length == 0 {
                // Device cannot place a call at this time.  SIM might be removed.
            }
            else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        }
        else {
            // iOS Device is not capable for making calls
        }
        
        return canMakeACall
    }
    
    func placeHolderTextView(_ textView: QMPlaceHolderTextView, shouldPasteWithSender sender: Any) -> Bool {
        
        if UIPasteboard.general.image != nil {
            
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIPasteboard.general.image!
            textAttachment.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
            
            let attrStringWithImage = NSAttributedString.init(attachment: textAttachment)
            self.inputToolbar?.contentView.textView.attributedText = attrStringWithImage
            self.textViewDidChange((self.inputToolbar?.contentView.textView)!)
            
            return false
        }
        
        return true
    }
    
    func showCharactersNumberError() {
        let title  = "SA_STR_ERROR".localized;
        let subtitle = String(format: "The character limit is %lu.", maxCharactersNumber)
        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: subtitle, type: .error)
    }
    
    /**
     Builds a string
     Read: login1, login2, login3
     Delivered: login1, login3, @12345
     
     If user does not exist in usersMemoryStorage, then ID will be used instead of login
     
     - parameter message: QBChatMessage instance
     
     - returns: status string
     */
    func statusStringFromMessage(message: QBChatMessage) -> String {
        
        var statusString = ""
        
        let currentUserID = NSNumber(value:self.senderID)
        
        var readLogins: [String] = []
        
        if message.readIDs != nil {
            
            let messageReadIDs = message.readIDs!.filter { (element) -> Bool in
                
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageReadIDs.isEmpty {
                for readID in messageReadIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(truncating: readID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(readID)"
                        readLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    readLogins.append(unwrappedUser.login!)
                }
                
                statusString += message.isMediaMessage() ? "SA_STR_SEEN_STATUS".localized : "SA_STR_READ_STATUS".localized;
                statusString += ": " + readLogins.joined(separator: ", ")
            }
        }
        
        if message.deliveredIDs != nil {
            var deliveredLogins: [String] = []
            
            let messageDeliveredIDs = message.deliveredIDs!.filter { (element) -> Bool in
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(truncating: deliveredID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(deliveredID)"
                        deliveredLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    if readLogins.contains(unwrappedUser.login!) {
                        continue
                    }
                    
                    deliveredLogins.append(unwrappedUser.login!)
                    
                }
                
                if readLogins.count > 0 && deliveredLogins.count > 0 {
                    statusString += "\n"
                }
                
                if deliveredLogins.count > 0 {
                    statusString += "SA_STR_DELIVERED_STATUS".localized + ": " + deliveredLogins.joined(separator: ", ")
                }
            }
        }
        
        if statusString.isEmpty {
            
            let messageStatus: QMMessageStatus = self.queueManager().status(for: message)
            
            switch messageStatus {
            case .sent:
                statusString = "SA_STR_SENT_STATUS".localized
            case .sending:
                statusString = "SA_STR_SENDING_STATUS".localized
            case .notSent:
                statusString = "SA_STR_NOT_SENT_STATUS".localized
            }
            
        }
        
        return statusString
    }
    
    // MARK: Override
    
    override func viewClass(forItem item: QBChatMessage) -> AnyClass {
        // TODO: check and add QMMessageType.AcceptContactRequest, QMMessageType.RejectContactRequest, QMMessageType.ContactRequest
        
        if item.isNotificationMessage() || item.isDateDividerMessage {
            return QMChatNotificationCell.self
        }
        
        if (item.senderID != self.senderID) {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentIncomingCell.self
                
            }
            else {
                
                return QMChatIncomingCell.self
            }
            
        }
        else {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentOutgoingCell.self
                
            }
            else {
                
                return QMChatOutgoingCell.self
            }
        }
    }
    
    // MARK: Strings builder
    
    override func attributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        
        guard messageItem.text != nil else {
            return nil
        }
        
        var textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black
        if messageItem.isNotificationMessage() || messageItem.isDateDividerMessage {
            textColor = UIColor.black
        }
        
        var attributes = Dictionary<NSAttributedStringKey, AnyObject>()
        attributes[NSAttributedStringKey.foregroundColor] = textColor
        attributes[NSAttributedStringKey.font] = UIFont(name: "Helvetica", size: 17)
        
        let attributedString = NSAttributedString(string: messageItem.text!, attributes: attributes)
        
        return attributedString
    }
    
    
    /**
     Creates top label attributed string from QBChatMessage
     
     - parameter messageItem: QBCHatMessage instance
     
     - returns: login string, example: @SwiftTestDevUser1
     */
    override func topLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        
        guard messageItem.senderID != self.senderID else {
            return nil
        }
        
        guard self.dialog.type != QBChatDialogType.private else {
            return nil
        }
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        var attributes = Dictionary<NSAttributedStringKey, AnyObject>()
        attributes[NSAttributedStringKey.foregroundColor] = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        attributes[NSAttributedStringKey.font] = UIFont(name: "Helvetica", size: 17)
        attributes[NSAttributedStringKey.paragraphStyle] = paragrpahStyle
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: messageItem.senderID)?.login {
            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        } else { // no user in memory storage
            topLabelAttributedString = NSAttributedString(string: "@\(messageItem.senderID)", attributes: attributes)
        }
        
        return topLabelAttributedString
    }
    
    /**
     Creates bottom label attributed string from QBChatMessage using self.statusStringFromMessage
     
     - parameter messageItem: QBChatMessage instance
     
     - returns: bottom label status string
     */
    override func bottomLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        var attributes = Dictionary<NSAttributedStringKey, AnyObject>()
        attributes[NSAttributedStringKey.foregroundColor] = textColor
        attributes[NSAttributedStringKey.font] = UIFont(name: "Helvetica", size: 13)
        attributes[NSAttributedStringKey.paragraphStyle] = paragrpahStyle
        
        let text = messageItem.dateSent != nil ? messageTimeDateFormatter.string(from: messageItem.dateSent!) : ""
        
//        if messageItem.senderID == self.senderID {
//            text = text + "\n" + self.statusStringFromMessage(message: messageItem)
//        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(_ collectionView: QMChatCollectionView!, dynamicSizeAt indexPath: IndexPath!, maxWidth: CGFloat) -> CGSize {
        
        var size = CGSize.zero
        
        guard let message = self.chatDataSource.message(for: indexPath) else {
            return size
        }
        
        let messageCellClass: AnyClass! = self.viewClass(forItem: message)
        
        
        if messageCellClass === QMChatAttachmentIncomingCell.self {
            
            size = CGSize(width: min(200, maxWidth), height: 200)
        }
        else if messageCellClass === QMChatAttachmentOutgoingCell.self {
            
            let attributedString = self.bottomLabelAttributedString(forItem: message)
            
            let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
        }
        else if messageCellClass === QMChatNotificationCell.self {
            
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        else {
            
            let attributedString = self.attributedString(forItem: message)
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        
        return size
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, minWidthAt indexPath: IndexPath!) -> CGFloat {
        
        var size = CGSize.zero
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return 0
        }
        
        if self.detailedCells.contains(item.id!) {
            
            let str = self.bottomLabelAttributedString(forItem: item)
            let frameWidth = collectionView.frame.width
            let maxHeight = CGFloat.greatestFiniteMagnitude
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(str, withConstraints: CGSize(width:frameWidth - kMessageContainerWidthPadding, height: maxHeight), limitedToNumberOfLines:0)
        }
        
        if self.dialog.type != QBChatDialogType.private {
            
            let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(self.topLabelAttributedString(forItem: item), withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
            
            if topLabelSize.width > size.width {
                size = topLabelSize
            }
        }
        
        return size.width
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, layoutModelAt indexPath: IndexPath!) -> QMChatCellLayoutModel {
        
        var layoutModel: QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAt: indexPath)
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5
        layoutModel.maxWidthMarginSpace = 20.0
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return layoutModel
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item) as AnyClass
        
        if viewClass === QMChatIncomingCell.self || viewClass === QMChatAttachmentIncomingCell.self {
            
            if self.dialog.type != QBChatDialogType.private {
                let topAttributedString = self.topLabelAttributedString(forItem: item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:1)
                layoutModel.topLabelHeight = size.height
            }
            
            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }
        
        var size = CGSize.zero
        
        if self.detailedCells.contains(item.id!) {
            
            let bottomAttributedString = self.bottomLabelAttributedString(forItem: item)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
        }
        
        layoutModel.bottomLabelHeight = floor(size.height)
        
        
        return layoutModel
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView, configureCell cell: UICollectionViewCell, for indexPath: IndexPath) {
        
        super.collectionView(collectionView, configureCell: cell, for: indexPath)
        
        // subscribing to cell delegate
        let chatCell = cell as! QMChatCell
        
        chatCell.delegate = self
        
        let message = self.chatDataSource.message(for: indexPath)
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            if attachmentCell is QMChatAttachmentIncomingCell {
                chatCell.containerView?.bgColor =  UIColor.init(red: (254/255.0), green: (254/255.0), blue: (254/255.0), alpha: 1.0)
                
                chatCell.containerView.layer.cornerRadius = 4;
              //  chatCell.containerView.layer.borderWidth = 1;
                chatCell.containerView.layer.borderColor = UIColor.lightGray.cgColor
                
               // chatCell.containerView.setShadow(radius: 4)
            }
            else if attachmentCell is QMChatAttachmentOutgoingCell {
                chatCell.containerView?.bgColor =  APPORANGECOLOR
            }
            
            if let attachment = message?.attachments?.first {
                
                var keysToRemove: [String] = []
                
                let enumerator = self.attachmentCellsMap.keyEnumerator()
                
                while let existingAttachmentID = enumerator.nextObject() as? String {
                    let cachedCell = self.attachmentCellsMap.object(forKey: existingAttachmentID as AnyObject?)
                    if cachedCell === cell {
                        keysToRemove.append(existingAttachmentID)
                    }
                }
                
                for key in keysToRemove {
                    self.attachmentCellsMap.removeObject(forKey: key as AnyObject?)
                }
                
                if let attachmentID = attachment.id {
                    if self.failedDownloads.contains(attachmentID) {
                        attachmentCell.setAttachmentImage(UIImage(named:"error_image"))
                        return
                    }
                }
                
                self.attachmentCellsMap.setObject(attachmentCell, forKey: attachment.id as AnyObject?)
                
                attachmentCell.attachmentID = attachment.id
                
                // Getting image from chat attachment cache.
                
                ServicesManager.instance().chatService.chatAttachmentService.image(forAttachmentMessage: message!, completion: { [weak self] (error, image) in
                    
                    guard attachmentCell.attachmentID == attachment.id else {
                        return
                    }
                    
                    self?.attachmentCellsMap.removeObject(forKey: attachment.id as AnyObject?)
                    
                    guard error == nil else {
                        if (error! as NSError).code == 404 {
                            self?.failedDownloads.insert(attachment.id!)
                            
                            attachmentCell.setAttachmentImage(UIImage(named:"error_image"))
                        }
                        logInfo(message:"Error downloading image from server: \(error!.localizedDescription)")
                        return
                    }
                    
                    if image == nil {
                        logInfo(message:"Image is nil")
                    }
                    
                    attachmentCell.setAttachmentImage(image)
                    cell.updateConstraints()
                })
            }
            
        }
        else if cell is QMChatIncomingCell || cell is QMChatAttachmentIncomingCell {
            
            chatCell.containerView?.bgColor = UIColor.init(red: (254/255.0), green: (254/255.0), blue: (254/255.0), alpha: 1.0)
            chatCell.containerView.layer.cornerRadius = 4;
            //chatCell.containerView.layer.borderWidth = 1;
            chatCell.containerView.layer.borderColor = UIColor.lightGray.cgColor
        }
        else if cell is QMChatOutgoingCell {
            
            let status: QMMessageStatus = self.queueManager().status(for: message!)
            
            switch status {
            case .sent:
                chatCell.containerView?.bgColor = APPORANGECOLOR
            case .sending:
                chatCell.containerView?.bgColor = APPORANGECOLOR
            case .notSent:
                chatCell.containerView?.bgColor = APPORANGECOLOR
            }
            
        }
        else if cell is QMChatAttachmentOutgoingCell {
            chatCell.containerView?.bgColor = APPORANGECOLOR
        }
        else if cell is QMChatNotificationCell {
            cell.isUserInteractionEnabled = false
            chatCell.containerView?.bgColor = self.collectionView?.backgroundColor
        }
    }
    
    /**
     Allows to copy text from QMChatIncomingCell and QMChatOutgoingCell
     */
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        guard let item = self.chatDataSource.message(for: indexPath) else {
            return false
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item) as AnyClass
        
        if  viewClass === QMChatNotificationCell.self ||
            viewClass === QMChatContactRequestCell.self {
            return false
        }
        
        return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        let item = self.chatDataSource.message(for: indexPath)
        
        if (item?.isMediaMessage())! {
            ServicesManager.instance().chatService.chatAttachmentService.localImage(forAttachmentMessage: item!, completion: { (image) in
                
                if image != nil {
                    guard let _ = UIImageJPEGRepresentation(image!, 1) else { return }
                    
                    let _ = UIPasteboard.general
                  //  kUTTypeJPEG
                   // pasteboard.setValue(imageData, forPasteboardType: as String)
                }
            })
        }
        else {
            UIPasteboard.general.string = item?.text
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let lastSection = self.collectionView!.numberOfSections - 1
        
        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItems(inSection: lastSection))! - 1) {
            // the very first message
            // load more if exists
            // Getting earlier messages for chat dialog identifier.
            
            guard let dialogID = self.dialog.id else {
                logInfo(message:"DialogID is nil")
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
            
            ServicesManager.instance().chatService.loadEarlierMessages(withChatDialogID: dialogID).continueWith(block: {[weak self](task) -> Any? in
                
                guard let strongSelf = self else { return nil }
                
                if (task.result?.count ?? 0 > 0) {
                    
                    strongSelf.chatDataSource.add(task.result as! [QBChatMessage]!)
                }
                
                return nil
            })
        }
        
        // marking message as read if needed
        if let message = self.chatDataSource.message(for: indexPath) {
            self.sendReadStatusForMessage(message: message)
        }
        
        return super.collectionView(collectionView, cellForItemAt
            : indexPath)
    }
    
    // MARK: QMChatCellDelegate
    
    /**
     Removes size from cache for item to allow cell expand and show read/delivered IDS or unexpand cell
     */
    func chatCellDidTapContainer(_ cell: QMChatCell!) {
        let indexPath = self.collectionView?.indexPath(for: cell)
        
        guard let currentMessage = self.chatDataSource.message(for: indexPath) else {
            return
        }
        
        let messageStatus: QMMessageStatus = self.queueManager().status(for: currentMessage)
        
        if messageStatus == .notSent {
            self.handleNotSentMessage(currentMessage, forCell:cell)
            return
        }
        
        if self.detailedCells.contains(currentMessage.id!) {
            self.detailedCells.remove(currentMessage.id!)
        } else {
            self.detailedCells.insert(currentMessage.id!)
        }
        
        self.collectionView?.collectionViewLayout.removeSizeFromCache(forItemID: currentMessage.id)
        self.collectionView?.performBatchUpdates(nil, completion: nil)
        
    }
    
    func chatCell(_ cell: QMChatCell!, didTapAtPosition position: CGPoint) {}
    
    func chatCell(_ cell: QMChatCell!, didPerformAction action: Selector!, withSender sender: Any!) {}
    
    func chatCell(_ cell: QMChatCell!, didTapOn result: NSTextCheckingResult) {
        
        switch result.resultType {
            
        case NSTextCheckingResult.CheckingType.link:
            
            let strUrl : String = (result.url?.absoluteString)!
            
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            
            if #available(iOS 9.0, *) {
                if hasPrefix {
                    
                    let controller = SFSafariViewController(url: URL(string: strUrl)!)
                    self.present(controller, animated: true, completion: nil)
                    
                    break
                }
                
            }
            // Fallback on earlier versions
            
            if UIApplication.shared.canOpenURL(URL(string: strUrl)!) {
                UIApplication.shared.open(URL.init(string: strUrl)!, options: [:], completionHandler: nil)
               // UIApplication.shared.openURL(URL(string: strUrl)!)
            }
            
            break
            
        case NSTextCheckingResult.CheckingType.phoneNumber:
            
            if !self.canMakeACall() {
                
               // SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call".localized, maskType: .none)
                break
            }
            
            let urlString = String(format: "tel:%@",result.phoneNumber!)
            let url = URL(string: urlString)
            
            self.view.endEditing(true)
            
            let alertController = UIAlertController(title: "",
                                                    message: result.phoneNumber,
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "SA_STR_CALL".localized, style: .destructive) { (action) in
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                
                //UIApplication.shared.openURL(url!)
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true) {
            }
            
            break
            
        default:
            break
        }
    }
    
    func chatCellDidTapAvatar(_ cell: QMChatCell!) {
    }
    
    // MARK: QMDeferredQueueManager
    
    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didAddMessageLocally addedMessage: QBChatMessage) {
        
        if addedMessage.dialogID == self.dialog.id {
            self.chatDataSource.add(addedMessage)
        }
    }
    
    func deferredQueueManager(_ queueManager: QMDeferredQueueManager, didUpdateMessageLocally addedMessage: QBChatMessage) {
        
        if addedMessage.dialogID == self.dialog.id {
            self.chatDataSource.update(addedMessage)
        }
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            if !(self.progressView?.isHidden)! {
                self.stopSpinProgress()
            }
            self.chatDataSource.add(messages)
        }
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            // Insert message received from XMPP or self sent
            if self.chatDataSource.messageExists(message) {
                
                self.chatDataSource.update(message)
            }
            else {
                
                self.chatDataSource.add(message)
            }
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if self.dialog.type != QBChatDialogType.private && self.dialog.id == chatDialog.id {
            self.dialog = chatDialog
            self.title = self.dialog.name
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatDataSource.update(message)
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatDataSource.update(messages)
        }
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Prevent crashing undo bug
        let currentCharacterCount = textView.text?.length ?? 0
        
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        
        if !QBChat.instance.isConnected { return true }
        
        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil
            
        } else {
            
            self.sendBeginTyping()
        }
        
        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(MessageViewController.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
        
        if maxCharactersNumber > 0 {
            
            if currentCharacterCount >= maxCharactersNumber && text.length > 0 {
                
                self.showCharactersNumberError()
                return false
            }
            
            let newLength = currentCharacterCount + text.length - range.length
            
            if  newLength <= maxCharactersNumber || text.length == 0 {
                return true
            }
            
            let oldString = textView.text ?? ""
            
            let numberOfSymbolsToCut = maxCharactersNumber - oldString.length
            
            var stringRange = NSMakeRange(0, min(text.length, numberOfSymbolsToCut))
            
            
            // adjust the range to include dependent chars
            stringRange = (text as NSString).rangeOfComposedCharacterSequences(for: stringRange)
            
            // Now you can create the short string
            let shortString = (text as NSString).substring(with: stringRange)
            
            let newText = NSMutableString()
            newText.append(oldString)
            newText.insert(shortString, at: range.location)
            textView.text = newText as String
            
            self.showCharactersNumberError()
            
            self.textViewDidChange(textView)
            
            return false
        }
        
        return true
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        
        super.textViewDidEndEditing(textView)
        
        self.fireSendStopTypingIfNecessary()
    }
    
    @objc func fireSendStopTypingIfNecessary() -> Void {
        
        if let timer = self.typingTimer {
            
            timer.invalidate()
        }
        
        self.typingTimer = nil
        self.sendStopTyping()
    }
    
    func sendBeginTyping() -> Void {
        self.dialog.sendUserIsTyping()
    }
    
    func sendStopTyping() -> Void {
        
        self.dialog.sendUserStoppedTyping()
    }
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChange status: QMMessageAttachmentStatus, for message: QBChatMessage) {
        
        if status != QMMessageAttachmentStatus.notLoaded {
            
            if message.dialogID == self.dialog.id {
                self.chatDataSource.update(message)
            }
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeLoadingProgress progress: CGFloat, for attachment: QBChatAttachment) {
        
        if let attachmentCell = self.attachmentCellsMap.object(forKey: attachment.id! as AnyObject?) {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeUploadingProgress progress: CGFloat, for message: QBChatMessage) {
        
        guard message.dialogID == self.dialog.id else {
            return
        }
        var cell = self.attachmentCellsMap.object(forKey: message.id as AnyObject?)
        
        if cell == nil && progress < 1.0 {
            
            if let indexPath = self.chatDataSource.indexPath(for: message) {
                cell = self.collectionView?.cellForItem(at: indexPath) as? QMChatAttachmentCell
                self.attachmentCellsMap.setObject(cell, forKey: message.id as AnyObject?)
            }
        }
        
        cell?.updateLoadingProgress(progress)
    }
    
    // MARK : QMChatConnectionDelegate
    
    func refreshAndReadMessages() {
        
      //  SVProgressHUD.show(withStatus: "SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.clear)
        self.loadMessages()
        
        if let messagesToRead = self.unreadMessages {
            self.readMessages(messages: messagesToRead)
        }
        
        self.unreadMessages = nil
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func queueManager() -> QMDeferredQueueManager {
        return ServicesManager.instance().chatService.deferredQueueManager
    }
    
    func handleNotSentMessage(_ message: QBChatMessage,
                              forCell cell: QMChatCell!) {
        
        let alertController = UIAlertController(title: "", message: "SA_STR_MESSAGE_FAILED_TO_SEND".localized, preferredStyle:.actionSheet)
        
        let resend = UIAlertAction(title: "SA_STR_TRY_AGAIN_MESSAGE".localized, style: .default) { (action) in
            self.queueManager().perfromDefferedAction(for: message, withCompletion: nil)
        }
        alertController.addAction(resend)
        
        let delete = UIAlertAction(title: "SA_STR_DELETE_MESSAGE".localized, style: .destructive) { (action) in
            self.queueManager().remove(message)
            self.chatDataSource.delete(message)
        }
        alertController.addAction(delete)
        
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        
        if alertController.popoverPresentationController != nil {
            self.view.endEditing(true)
            alertController.popoverPresentationController!.sourceView = cell.containerView
            alertController.popoverPresentationController!.sourceRect = cell.containerView.bounds
        }
        
        self.present(alertController, animated: true) {
        }
    }
    
    //MARK: - Service Helper Methods
    func callAPIToUnFrinedUser(){
        
        if self.userID.count == 0{
            showAlert(title: "Warning", message: "Something went wrong!", controller: self)
            return
        }
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["friend_user_id"] =  self.userID as AnyObject
        
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
                    self.menuView.isHidden = true
                    showAlert(title: "Success", message: "Friend block successfully.", controller: self, acceptBlock: {
                        self.navigationController?.popViewController(animated: true)
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
    
    func callAPIToReportUser(){
        
        if self.userID.count == 0{
            showAlert(title: "Warning", message: "Something went wrong!", controller: self)
            return
        }
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["to_user_id"] =  self.userID as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: "report") { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue("status_code", expected: 0 as AnyObject) as! Int) == 200 {
                    self.menuView.isHidden = true
                    showAlert(title: "Success", message: "Your report has been sent successfully.", controller: self, acceptBlock: {
                        
                    })
                    
                }else{
                    showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    
    func callAPIToSendErrorMessage(message: String){
        
        if self.userID.count == 0{
            showAlert(title: "Warning", message: "Something went wrong!", controller: self)
            return
        }
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams["from_user_id"] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["to_user_id"] =  self.userID as AnyObject
        dictParams["message"] =  message as AnyObject
        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: false, params: dictParams , apiName: "report-err") { (response, error) in
            if error != nil {
//                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
//                if (responseDict.validatedValue("status_code", expected: 0 as AnyObject) as! Int) == 200 {
//                    self.menuView.isHidden = true
//                    showAlert(title: "Success", message: "Your report has been sent successfully.", controller: self, acceptBlock: {
//
//                    })
//
//                }else{
//                    showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
//                }
            } else {
               // showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
}
