//
//  NotesViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 26/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    //outlet
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var notesTextView: UITextView!
    
    //instance Variable
    var friendUserID: String = ""
    var notesList = [NotesInfo]()
    var pageNumber: Int = 1
    var totalPage: Int = 1

    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialMethods()
        self.callAPIToGetNotes()

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Helper Methods
    func initialMethods(){
        
        topView.setShadow(radius: 0)
        
        self.notesTextView.layer.cornerRadius = 4;
        self.notesTextView.layer.borderWidth = 1;
        self.notesTextView.layer.borderColor = UIColor.lightGray.cgColor;
        self.notesTextView.text = "Write note here.."
        notesTextView.textColor = UIColor.lightGray
        notesTextView.delegate = self
    }
    
    //MARK: - UITextView Delegate Methods
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if notesTextView.text == "Write note here.."{
            notesTextView.text = ""
            notesTextView.textColor = UIColor.black
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView){
        if notesTextView.text == ""{
            notesTextView.text = "Write note here.."
            notesTextView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: - IBAction Methods
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        if notesTextView.text == "Write note here.."{
            showAlert(title: "Warning", message: "Please enter notes.", controller: self)
        }else{
            self.callAPIToAddNotes()
        }
        
    }
    
    //MARK: - UITableView Delegate and DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notesList.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell: NotesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell") as! NotesTableViewCell
        let obj = notesList[indexPath.row]
        
        cell.titleLabel.text = obj.createdDate.getDateWithDDMMMYYYYHHMMAFormat()
        cell.descriptionLabel.text = obj.noteStr
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK:- UIScrollViewDelegate Methods
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((notesTableView.contentOffset.y + notesTableView.frame.size.height) >= notesTableView.contentSize.height) {
            if pageNumber < totalPage{
                pageNumber += 1
                self.callAPIToGetNotes()
            }
        }
    }
   
    
    //MARK:- Service Helper Methods
    func callAPIToAddNotes(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] = UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["profile_user_id"] = "1" as AnyObject //self.friendUserID as AnyObject
        dictParams["note"] = self.notesTextView.text as AnyObject

        
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kAddNotesAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                   
                   // showAlert(title: "Success", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                    self.notesTextView.text = "Write note here.."
                    self.notesTextView.textColor = UIColor.lightGray
                    self.pageNumber = 1
                    self.notesList.removeAll()
                    self.callAPIToGetNotes()
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
                }
            } else {
                showAlert(title: "Error", message: "Something went wrong!", controller: self)
                return
            }
        }
    }
    
    //call api to fetch notes list
    func callAPIToGetNotes(){
        
        var dictParams = Dictionary<String,AnyObject>()
        dictParams[kUserID] =  UserDefaults.standard.string(forKey: kUserID) as AnyObject
        dictParams["profile_user_id"] = "1" as AnyObject //self.friendUserID as AnyObject
        dictParams["page"] = pageNumber as AnyObject
        ServiceHelper.sharedInstance.createPostRequest(isShowHud: true, params: dictParams , apiName: kFetchNotesAPI) { (response, error) in
            if error != nil {
                showAlert(title: "Error", message: (error?.localizedDescription)!, controller: self)
                return
            }
            
            if (response != nil) {
                guard let responseDict = response as? Dictionary<String,Any> else {
                    return
                }
                if (responseDict.validatedValue(kStatus, expected: 0 as AnyObject) as! Int) == 200 {
                    
                    self.notesList = NotesInfo.getNotesListWithDictionryList(list: responseDict.validatedValue(kData, expected: [] as AnyObject) as! [Dictionary<String, AnyObject>], notesList: self.notesList)
                    self.totalPage = responseDict.validatedValue("last_page", expected: 0 as AnyObject) as! Int
                    self.notesTableView.reloadData()
                    
                }else{
                    showAlert(title: "Warning", message: responseDict.validatedValue(kResponseMessage, expected: "" as AnyObject) as! String, controller: self)
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
