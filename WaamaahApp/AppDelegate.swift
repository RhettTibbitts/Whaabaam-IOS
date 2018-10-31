//
//  AppDelegate.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit
import SystemConfiguration
import CoreLocation
import NotificationCenter
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, NotificationServiceDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var navigationController : UINavigationController = UINavigationController()
    var secondNavController : UINavigationController = UINavigationController()
    var locationManager:CLLocationManager!
    var timer:Timer!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true

        UserDefaults.standard.set(false, forKey: "isTerminate")
        UserDefaults.standard.synchronize()
        
        self.setStatusBarBackgroundColor()
        self.quickBloxSetup()
        self.updateUserLocation()
        self.setInitialController()
        self.callAPIToSendLocation()
       
        //register for push notification
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        //////////////////////////////////////////////////
        
        timer = Timer.scheduledTimer(timeInterval: 300.0, target: self, selector: #selector(self.callAPIToSendLocation), userInfo: nil, repeats: true)
        // app was launched from push notification, handling it
        let remoteNotification: NSDictionary! = launchOptions?[.remoteNotification] as? NSDictionary
        if (remoteNotification != nil) {
            ServicesManager.instance().notificationService.pushDialogID = remoteNotification["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String
        }
        
        return true
    }

   
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.set(true, forKey: "isTerminate")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - PushNotification Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString
        Messaging.messaging().apnsToken = deviceToken
        
        UserDefaults.standard.set(deviceIdentifier, forKey: "deviceIdentifier")
        UserDefaults.standard.set(deviceToken, forKey: "device_token")
        UserDefaults.standard.synchronize()
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            logInfo(message: "uy")
        }) { (response: QBResponse!) -> Void in
            logInfo(message: "sdcd")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        guard let dialogID = userInfo["dialog_id"] as? String else {
            guard let messageType = ((userInfo.validatedValue("aps", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("alert", expected: [:] as AnyObject) as! Dictionary<String, AnyObject>).validatedValue("event_type", expected: "" as AnyObject) as? String else {
                return
            }
            
            if messageType == "FRIEND_REQ"{
                self.goToControllerAtindex(index: 2)
            }else if messageType == "CLOSE_CONTACT"{
                self.goToControllerAtindex(index: 0)
            }
            
            return
        }

        guard !dialogID.isEmpty else {
            return
        }
        
        let dialogWithIDWasEntered: String? = ServicesManager.instance().currentDialogID
        if dialogWithIDWasEntered == dialogID {
            return
        }
        
        ServicesManager.instance().notificationService.pushDialogID = dialogID
        UIApplication.shared.applicationIconBadgeNumber = 0
        DispatchQueue.main.async {
            ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(delegate: self)
        }
    }
    
    //MARK: - Firebase Message Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        UserDefaults.standard.set(fcmToken, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
      
    }
    
    // MARK: NotificationServiceDelegate protocol
    func notificationServiceDidStartLoadingDialogFromServer() {
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        
        let navigatonController: UINavigationController! = self.window?.rootViewController as! UINavigationController
        
        let chatController: MessageViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        chatController.dialog = chatDialog
         self.connectUserWithChat()
        for controller in navigationController.viewControllers{
            if controller.isKind(of: TabBarViewController.self){
                self.navigationController.popToViewController(controller, animated: false)
            }
        }
        
        let dict = ["index":1]
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil, userInfo: dict )
       
        navigatonController.pushViewController(chatController, animated: true)

    }
    
    func notificationServiceDidFailFetchingDialog() {
        
    }

    //MARK: - Helper Methods
    func setInitialController(){
        
        if UserDefaults.standard.string(forKey: kAccessToken)?.count == 0 || UserDefaults.standard.string(forKey: kAccessToken) == nil{
            let routeVC = authStoryboard.instantiateViewController(withIdentifier: "RouteViewController")
            navigationController = UINavigationController.init(rootViewController:routeVC)

        }else{
            if UserDefaults.standard.bool(forKey: "isEdit"){
                let objVC = settingStoryboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                objVC.isFromLogin = true
                navigationController = UINavigationController.init(rootViewController:objVC)
            }else{
                let objVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                navigationController = UINavigationController.init(rootViewController:objVC)
            }
        }

        navigationController.setNavigationBarHidden(true, animated: false)
        APPDELEGATE.window?.rootViewController = navigationController
        
        
//        let routeVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarViewController")
//        navigationController = UINavigationController.init(rootViewController:routeVC)
//        navigationController.setNavigationBarHidden(true, animated: false)
//        APPDELEGATE.window?.rootViewController = navigationController

        
    }
    
    
    func goToControllerAtindex(index:Int){
        for controller in navigationController.viewControllers{
            if controller.isKind(of: TabBarViewController.self){
                if controller != self.navigationController.topViewController{
                    self.navigationController.popToViewController(controller, animated: false)
                }
            }
        }
        let dict = ["index":index]
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil, userInfo: dict )
    }
    
    
    //MARK:- Setup For User Location And Location Manager Delegate Methods
    func updateUserLocation(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func isLocationEnabled()-> Bool{
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        logInfo(message:"locations = \(locations)")
        
        if locations.count >= 1{
            UserDefaults.standard.set(locations[0].coordinate.latitude, forKey: "lat")
            UserDefaults.standard.set(locations[0].coordinate.longitude, forKey: "lng")
            UserDefaults.standard.synchronize()
            self.getAddressFromLatLon(pdblLatitude: locations[0].coordinate.latitude, withLongitude: locations[0].coordinate.longitude)
            
        }
        
    }
    
    //MARK:- Get Address From Lattitude and longitude
    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = pdblLatitude
        //21.228124
        let lon: Double = pdblLongitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    logInfo(message:"reverse geodcode fail: \(error!.localizedDescription)")
                }
                if placemarks == nil{
                    return
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    UserDefaults.standard.set(addressString, forKey: "address")
                    UserDefaults.standard.synchronize()
                    self.callAPIToSendLocation()
                }
        })
    }
    
    //MARK:- To Check Reachability
    func checkReachablility() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    //MARK:- QuickBlox Setup Methods
    func quickBloxSetup(){
        
        //demo quickblox id
//        QBSettings.applicationID = 72448
//        QBSettings.authKey = "f4HYBYdeqTZ7KNb"
//        QBSettings.authSecret = "ZC7dK39bOjVc-Z8"
//        QBSettings.accountKey = "C4_z7nuaANnBYmsG_k98"
      
        //stagig quickblox account
//        QBSettings.applicationID = 72672
//        QBSettings.authKey = "vJMB-BxvStDACPx"
//        QBSettings.authSecret = "XGxR7gcbeVekQWt"
//        QBSettings.accountKey = "KpsYvz4bzP_Tn9iVMAwx"
        
      //  client Quickblox account
        QBSettings.applicationID = 73836
        QBSettings.authKey = "BcJD6OSKVjMvrgf"
        QBSettings.authSecret = "8Xwq9aMjqJQUZsO"
        QBSettings.accountKey = "MyY6PNzMzXELYxj8vRbo"
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
    }

    func connectUserWithChat(){
        
        if let currentUser:QBUUser = ServicesManager.instance().currentUser {
            let user = QBUUser()
            user.id = currentUser.id
            let password = "\(currentUser.login ?? "")WXYZ1234"
            user.password = password.toBase64()
            QBChat.instance.connect(withUserID: user.id, password: user.password!) { (error) in
                
                if error != nil{
                    //showAlert(title: "Error", message: "Chat not connected.", controller: self)
                }
            }
        }
        
    }
    
    func createNewDailog(quickBloxId: UInt){
        
        showHud()
        APPDELEGATE.connectUserWithChat()
        QBRequest.user(withID: quickBloxId, successBlock: { (response, user) in
            
            if response.status.rawValue == 200{
                
                ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: user, completion: { (response, chatDialog) in
                    hideHud()
                    if chatDialog != nil{
                        self.getAllUsers()
                        
                        let objVC = mainStoryboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
                        objVC.isFirstTime = true
                        objVC.dialog = chatDialog
                        self.navigationController.pushViewController(objVC, animated: true)
                    }
                })
            }
        }) { (error) in
            hideHud()
        }
    }
    
    func logInChatWithUser(user: QBUUser) {
        
        showHud()
        let password = "\(user.login ?? "")WXYZ1234"
        user.password = password
        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logIn(with: user, completion:{
             (success, errorMessage) -> Void in
            hideHud()
            guard success else {
                logInfo(message:"connect")
                self.getAllUsers()
                return
            }
        })
    }
    
    func sbscriptionSetup()  {
        
        if (UserDefaults.standard.string(forKey: "deviceIdentifier")?.count == 0 || UserDefaults.standard.string(forKey: "deviceIdentifier") == nil ) || (UserDefaults.standard.string(forKey: "device_token")?.count == 0 || UserDefaults.standard.string(forKey: "device_token") == nil ) {
            
            return
        }
        
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = (UserDefaults.standard.value(forKey: "deviceIdentifier") as! String)
        subscription.deviceToken = (UserDefaults.standard.value(forKey: "device_token") as! Data)
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            logInfo(message: "uy")
        }) { (response: QBResponse!) -> Void in
            logInfo(message: "sdcd")
        }
    }
    
    //setStatusBar color
    func setStatusBarBackgroundColor() {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = UIColor.black
    }
    
    
    //MARK:- Call APi To Send Location
    @objc func callAPIToSendLocation(){
        
        if UserDefaults.standard.string(forKey: kUserID)?.count == 0 || UserDefaults.standard.string(forKey: kUserID) != nil {
            var dictParams = Dictionary<String,AnyObject>()
            dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
            dictParams["lat"] = UserDefaults.standard.value(forKey: "lat") as AnyObject
            dictParams["lng"] = UserDefaults.standard.value(forKey: "lng") as AnyObject
            dictParams["address"] = UserDefaults.standard.value(forKey: "address") as AnyObject
            
            ServiceHelper.sharedInstance.createPostRequest(isShowHud: false, params: dictParams , apiName: kSendLocationAPI) { (response, error) in
                if error != nil {
                    return
                }
                
                if (response != nil) {
                } else {
                    return
                }
            }
        }
       
    }
    
    //download current user envirronment
    func getAllUsers(){
        ServicesManager.instance().downloadCurrentEnvironmentUsers(successBlock: { (users) -> Void in
            
            logInfo(message: "great...")
            
        }, errorBlock: { (error) -> Void in
            logInfo(message: "Error...\(error)")

        })
    }
}


