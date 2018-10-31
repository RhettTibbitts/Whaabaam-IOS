//
//  FilterInfo.swift
//  WaamaahApp
//
//  Created by Ashish on 03/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class FilterInfo: NSObject {

    var nameStr : String = ""
    var idStr : String = ""
    var isSelected: Bool = false
    
    class func getKeywordList(list:[Dictionary<String, AnyObject>]) -> [FilterInfo]{
    
        var keywordList = [FilterInfo]()
        
        for dict in list{
            let obj = FilterInfo()
            obj.nameStr = dict.validatedValue("name", expected: "" as AnyObject) as! String
            obj.idStr = dict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.isSelected = dict.validatedValue("selected", expected: false as AnyObject) as! Bool
            keywordList.append(obj)
        }
        return keywordList
    }
}
