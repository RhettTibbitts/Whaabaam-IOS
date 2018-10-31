//
//  RouteViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {

    //Outlet
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    //MARK - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK - Helper Methods
    func initialMethods(){
        
        self.signupBtn.layer.cornerRadius = self.signupBtn.layer.frame.size.height / 2
        self.loginBtn.layer.cornerRadius = self.loginBtn.layer.frame.size.height / 2
        self.loginBtn.layer.borderWidth = 1
        self.loginBtn.layer.borderColor = UIColor.black.cgColor
       
    }

    //MARK - UIButton Action Methods
    @IBAction func commonBtnAction(_ sender: UIButton) {
        
        if sender.tag == 100{
            //signup btn action
            self.loginBtn.setTitleColor(UIColor.black, for: .normal)
            self.loginBtn.layer.borderWidth = 1
            self.loginBtn.backgroundColor = UIColor.white
            
            self.signupBtn.setTitleColor(UIColor.white, for: .normal)
            self.signupBtn.backgroundColor = APPORANGECOLOR
            self.signupBtn.layer.borderWidth = 0;
            let objVC = authStoryboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            self.navigationController?.pushViewController(objVC, animated: true)
            
        }else {
            //login btn action
            self.loginBtn.setTitleColor(UIColor.white, for: .normal)
            self.loginBtn.layer.borderWidth = 0
            self.loginBtn.backgroundColor = APPORANGECOLOR
            
            self.signupBtn.layer.borderWidth = 1;
            self.signupBtn.setTitleColor(UIColor.black, for: .normal)
            self.signupBtn.backgroundColor = UIColor.white
        
            let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        
    }
    
    //MARK- Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
