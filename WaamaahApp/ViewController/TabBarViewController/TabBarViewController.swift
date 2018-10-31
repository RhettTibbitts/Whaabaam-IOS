//
//  TabBarViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 17/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class TabBarViewController: UIViewController {

    //outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var feedbackBtn: UIButton!
    @IBOutlet weak var connectionBtn: UIButton!
    @IBOutlet weak var notificationBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var mainContainerView: UIView!
    
    //instance variable
    var feedBackVC : FeedBackViewController!
//    var connectionVC : ConnectionViewController!
    var chatList : ChatListViewController!
    var notificationVC : NotificationViewController!
    var settingVC : SettingsViewController!
    
    var navFeedBack: UINavigationController!
    var navCoonection: UINavigationController!
    var navNotification: UINavigationController!
    var navSetting: UINavigationController!
    var controller : UINavigationController!
    var controllerArray : Array<UINavigationController>!

    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethods(){
        self.setsNavigationController()
       
        self.setInitialController(index: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)

    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        
        guard let index = notification.userInfo!["index"] as? Int else{
            return
        }
        self.resetSelectedBtn()
        if index == 0{
            self.feedbackBtn.isSelected = true
        }else if index == 1{
            self.connectionBtn.isSelected = true
        }else if index == 2{
            notificationBtn.isSelected = true
        }
        setInitialController(index: index)
    }
    
    func resetSelectedBtn(){
        feedbackBtn.isSelected = false;
        connectionBtn.isSelected = false;
        notificationBtn.isSelected = false;
        settingBtn.isSelected = false;
    }
    
    private func setsNavigationController() {
        
        feedBackVC = mainStoryboard.instantiateViewController(withIdentifier: "FeedBackViewController") as! FeedBackViewController
        chatList = mainStoryboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        notificationVC = mainStoryboard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        settingVC = settingStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        
        self.navFeedBack = UINavigationController(rootViewController: feedBackVC)
        self.navCoonection = UINavigationController(rootViewController: chatList)
        self.navNotification = UINavigationController(rootViewController: notificationVC)
        self.navSetting = UINavigationController(rootViewController: settingVC)
        
        self.controllerArray = [self.navFeedBack,self.navCoonection,self.navNotification,self.navSetting]
    }
    
    func setInitialController(index : Int){
        self.controllerArray = [self.navFeedBack,self.navCoonection,self.navNotification,self.navSetting]
        
        for subview in mainContainerView.subviews {
            subview.removeFromSuperview()
        }
        self.controller = self.controllerArray[index]
        controller.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(controller.view)
        self.addChildViewController(controller)
        
        controller.didMove(toParentViewController: self)
        self.controller.isNavigationBarHidden = true
        self.view.endEditing(true)
        if controller.viewControllers.count > 1 {
            controller.popToRootViewController(animated: false)
        }
        
    }
    
//    func setInitialController(index : Int){
//
//        feedBackVC.view.removeFromSuperview()
//        connectionVC.view.removeFromSuperview()
//        notificationVC.view.removeFromSuperview()
//        settingVC.view.removeFromSuperview()
//
//        switch index {
//        case 0:
//            self.mainContainerView.frame = self.feedBackVC.view.frame
//            self.mainContainerView.addSubview(self.feedBackVC.view)
//            break
//        case 1:
//            self.mainContainerView.frame = self.connectionVC.view.frame
//            self.mainContainerView.addSubview(self.connectionVC.view)
//            break
//        case 2:
//            self.mainContainerView.frame = self.notificationVC.view.frame
//            self.mainContainerView.addSubview(self.notificationVC.view)
//            break
//        case 3:
//            self.mainContainerView.frame = self.settingVC.view.frame
//            self.mainContainerView.addSubview(self.settingVC.view)
//            break
//        default:
//            break
//        }
//
//    }
    
    //MARK: - IBAction Methods
    @IBAction func tabCommonBtnAction(_ sender: UIButton) {
        
        self.resetSelectedBtn()
        sender.isSelected = true
        self.setInitialController(index: sender.tag - 100)
        
    }
    

    //MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
