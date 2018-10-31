//
//  NotesInfo.swift
//  WaamaahApp
//
//  Created by Ashish on 23/08/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import UIKit

class NotesInfo: NSObject {

    var createdDate: Date!
    var notesID: String = ""
    var noteStr: String = ""

    class func getNotesListWithDictionryList(list:[Dictionary<String, AnyObject>], notesList:[NotesInfo])-> [NotesInfo]{
        
        var tempList = notesList
        
        for dict in list{
            
            let obj = NotesInfo()
            obj.createdDate = (dict.validatedValue("created_at", expected: "" as AnyObject) as! String).dateFromString(format: "yyyy-MM-dd HH:mm:ss") as! Date
            obj.notesID = dict.validatedValue("id", expected: "" as AnyObject) as! String
            obj.noteStr = dict.validatedValue("note", expected: "" as AnyObject) as! String
            tempList.append(obj)
        }
        
        return tempList
    }
    
}
