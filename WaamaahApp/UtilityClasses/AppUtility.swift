//
//  AppUtility.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

let APPORANGECOLOR = UIColor.init(red: (242/255.0), green: (108/255.0), blue: (83/255.0), alpha: 1.0)
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
let authStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let settingStoryboard = UIStoryboard(name: "Settings", bundle: nil)
let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
let isPrint = true

let WINDOW_WIDTH = UIScreen.main.bounds.width
let WINDOW_HEIGHT = UIScreen.main.bounds.height

enum FriendRequestStatus {
    case FriendRequestSend
    case Friend
    case Unfriend
    case IsFromRequestSend
    case IsFromApproveReject
    case IsCancelFriendRequest
    case IsUnfriendOfFriend
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}


class AppUtility: NSObject {
 
    
    
}

func showAlert(title:String, message:String, controller:UIViewController){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler:nil)
    alertController.addAction(defaultAction)
    controller.present(alertController, animated: true, completion: nil)
}

func showAlert(title: String, message: String, controller:UIViewController, acceptBlock: @escaping () -> ()) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let acceptButton = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
        acceptBlock()
    })
    alertController.addAction(acceptButton)
    controller.present(alertController, animated: true, completion: nil)
}



func logInfo(message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    if (isPrint) {
        print("\(function): \(line): \(message)")
    }
}

//MARK:- HUD
func showHud() {
    let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
    RappleActivityIndicatorView.startAnimating(attributes: attribute)
}

func hideHud() {
    RappleActivityIndicatorView.stopAnimation()
    RappleActivityIndicatorView.stopAnimation(completionIndicator: .none, completionLabel: "", completionTimeout: 1.0)
}

//get day by adding in date
func getDateByAddingDay(value : Int, date: Date) -> Date {
    return Calendar.current.date(byAdding: .day, value: -value, to: getNoon(date: date))!
}

func getNoon(date : Date) -> Date {
    return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
}

