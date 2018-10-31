//
//  FilterViewController.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 27/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

protocol FilterPopupProtocal {
    func dissmissFilterPopup(selectedIDs:[String])
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var filterTableView: UITableView!
    
    //instance variable
    var completionHandler: (()->Void)?
    var itemList  = [Dictionary<String, AnyObject>]()
    var selectedContent = [String]()
    var delegate:FilterPopupProtocal!
    
    //MARK: - UIViewLifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inititialMethods()
    }
    
    //MARK: - Helper Methods
    func inititialMethods(){
        itemList = [["title":"Hide Connections" as AnyObject,"id":"hide_friends" as AnyObject],
                    ["title":"Hide Strangers" as AnyObject,"id":"hide_strangers" as AnyObject],
                    ["title":"City" as AnyObject,"id":"city_id" as AnyObject],
                    ["title":"State" as AnyObject,"id":"state_id" as AnyObject],
                    ["title":"Occupation" as AnyObject,"id":"occupation" as AnyObject],
                    ["title":"Education" as AnyObject,"id":"education" as AnyObject],
                    ["title":"High School" as AnyObject,"id":"high_school" as AnyObject],
                    ["title":"College" as AnyObject,"id":"college" as AnyObject],
                    ["title":"Alma Matter" as AnyObject,"id":"alma_matter" as AnyObject],
                    ["title":"Likes, hobbies, interests" as AnyObject,"id":"likes" as AnyObject],
                    ["title":"Military" as AnyObject,"id":"military_id" as AnyObject],
                    ["title":"Political" as AnyObject,"id":"political_id" as AnyObject],
                    ["title":"Religion" as AnyObject,"id":"religion_id" as AnyObject],
                    ["title":"Relationship Status" as AnyObject,"id":"relationship_id" as AnyObject]]
        self.filterTableView.isScrollEnabled = true
        self.filterTableView.isUserInteractionEnabled = true
    }
    
    //MARK: - IBAction Methods
    @IBAction func transparentBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func crossBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearAll(_ sender: Any) {
        selectedContent.removeAll()
        self.filterTableView.reloadData()
    }
    @IBAction func applyBtnAction(_ sender: Any) {
        
        logInfo(message: selectedContent.joined(separator: ","))
        self.dismiss(animated: true, completion: {
            self.delegate.dissmissFilterPopup(selectedIDs: self.selectedContent)
        })
    }
    
    //MARK: - UITableView Delegate and DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return itemList.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let dict = itemList[indexPath.row]
        
        if selectedContent.contains(dict["id"] as! String){
            selectedContent.remove(at: selectedContent.index(of: dict["id"] as! String)!)
        }else{
            selectedContent.append(dict["id"] as! String)
        }
        self.filterTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell: ImageLabelTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ImageLabelTableViewCell") as! ImageLabelTableViewCell
        cell.xConstant.constant = 0
        cell.rightConstant.constant = 0
        cell.titelLabel.text = itemList[indexPath.row]["title"] as? String;
        if selectedContent.contains(itemList[indexPath.row]["id"] as! String) {
            cell.contentImageView.image = #imageLiteral(resourceName: "check")
        }else{
            cell.contentImageView.image = #imageLiteral(resourceName: "uncheck")
        }
        
//        if indexPath.row == 7{
//            cell.separatorLabel.isHidden = true
//        }
        return cell
    }
    
    //MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
