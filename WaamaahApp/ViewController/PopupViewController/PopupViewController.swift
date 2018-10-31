//
//  PopupViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 25/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

@objc protocol RequestPopupProtocol: class {
    func sendFriendRequest()
    @objc optional func rejectFriendrequest()
    @objc optional func cancelFriendRequest()
    @objc optional func unFriendOfFriend()

}

class PopupViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var gotItBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var yesSendBtn: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    //instance variable
    var isFromRequestSend = false
    weak var popupDelegate : RequestPopupProtocol?
    var messageString:String!
    var isFromApproveReject = false
    var isCancelFriendRequest = false
    var friendRequestStatus = FriendRequestStatus.Friend
    var titleString = ""
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
    }
    
    
    //MARK: - Helper Methods
    func initialMethods(){
        
        self.yesSendBtn.layer.cornerRadius = 18
        self.cancelBtn.layer.cornerRadius = 18
        self.gotItBtn.layer.cornerRadius = 18

        if isFromRequestSend {
            self.titleLabel.text = "Request Sent"
            self.messageLabel.text = messageString
            self.yesSendBtn.isHidden = true
            self.cancelBtn.isHidden = true
            self.gotItBtn.isHidden = false
        }else{
            self.titleLabel.text = "Connection Request"
            self.messageLabel.text = messageString
            self.yesSendBtn.isHidden = false
            self.cancelBtn.isHidden = false
            self.gotItBtn.isHidden = true
        }
        
        if isFromApproveReject {
            self.yesSendBtn.setTitle("Approve", for: .normal)
            self.cancelBtn.setTitle("Cancel", for: .normal)
        }
        
        if titleString.count != 0 {
            titleLabel.text = titleString
        }
        
    }
    
    //MARK: -IBAction Methods
    @IBAction func yesBtnAction(_ sender: Any) {
        isFromRequestSend = true
        if isFromApproveReject {
            popupDelegate?.rejectFriendrequest!()
            self.dismiss(animated: true, completion: nil)
            return
        }
        switch self.friendRequestStatus {
        case .IsCancelFriendRequest:
            popupDelegate?.cancelFriendRequest!()
        case .IsUnfriendOfFriend:
            popupDelegate?.unFriendOfFriend!()
        default:
            popupDelegate?.sendFriendRequest()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        
//        if isFromApproveReject{
//            popupDelegate?.rejectFriendrequest!()
//        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gotItBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
