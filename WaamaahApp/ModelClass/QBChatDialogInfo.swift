//
//  QBChatDialogInfo.swift
//  WaamaahApp
//
//  Created by Ashish on 31/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import AVFoundation
class QBChatDialogInfo: NSObject {

    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?
    var userImage = ""
    override init() {
        
    }
    
    init(dialog: QBChatDialog) {
        super.init()
        
        switch (dialog.type){
        case .publicGroup:
            self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
        case .group:
            self.detailTextLabelText = "SA_STR_GROUP".localized
        case .private:
            self.detailTextLabelText = "SA_STR_PRIVATE".localized
            
            if dialog.recipientID == -1 {
                return
            }
            // Getting recipient from users service.
            
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
                //self.textLabelText = recipient.login ?? recipient.email!
                if recipient.customData?.count != 0 && recipient.customData != nil{
                    self.userImage = recipient.customData!
                }
            }
        }
        
        if self.textLabelText.isEmpty {
            // group chat
            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }
        
        // Unread messages counter label
        if (dialog.unreadMessagesCount > 0) {
            
            var trimmedUnreadMessageCount : String
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            
            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false
            
        }
        else {
            
            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }
        
        // Dialog icon
        
        if dialog.type == .private {
            self.dialogIcon = UIImage(named: "user")
        }
        else {
            self.dialogIcon = UIImage(named: "group")
        }
        
        if self.dialogIcon == nil {
            self.dialogIcon = #imageLiteral(resourceName: "placeholder")
        }
    }
    
}
