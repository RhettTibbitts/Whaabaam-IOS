//
//  StringExtension.swift
//  WaamaahApp
//
//  Created by Ashish Kumar singh on 09/07/18.
//  Copyright © 2018 Xicom All rights reserved.
//

import Foundation
import UIKit

extension String{
    
    func isValidName() -> Bool {
        
        let nameRegEx = "^[a-zA-Z\\s]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func isValidUrl() -> Bool {
        let regex: String = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return urlTest.evaluate(with: self)
    }
    
    func isValidMobileNumber() -> Bool {
        
        let mobileNoRegEx = "^((\\+)|(00)|(\\*)|())[0-9]{10,14}((\\#)|())$"
        let mobileNoTest = NSPredicate(format:"SELF MATCHES %@", mobileNoRegEx)
        return mobileNoTest.evaluate(with: self)
    }
    
    
    func isValidUserName() -> Bool {
        
        let nameRegEx = "^[a-zA-Z0-9\\s]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let passwordRegEx = "^[A-Za-z0-9]+(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,16}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
    
    func containsNumberOnly() -> Bool {
        
        let nameRegEx = "^[0-9]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func containsAlphabetsOnly() -> Bool {
        
        let nameRegEx = "^[a-zA-Z]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func containsAlphaNumericOnly() -> Bool {
        
        let nameRegEx = "^[a-zA-Z0-9]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    
    
    func dateFromString(format:String) -> NSDate? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = dateFormatter.date(from: self) {
            return date as NSDate?
        } else {
          logInfo(message:"Unable to format date")
        }
        
        return nil
    }
    
    
    
    //>>>> removes all whitespace from a string, not just trailing whitespace <<<//
    
    func removeWhitespace() -> String {
        return self.replaceString(string: " ", withString: "")
    }
    
    //>>>> Replacing String with String <<<//
    func replaceString(string:String, withString:String) -> String {
        return self.replacingOccurrences(of: string, with: withString,options:NSString.CompareOptions.literal,range: nil )
    }
    
    func addDayExtensionInDate() -> String {
        if self.count == 0{
            return ""
        }
        let tempArray = self.components(separatedBy: " ")
        if tempArray.count < 2{
            return ""
        }
        let day: Int = Int(tempArray[1])!
        return "\(tempArray[0]) \(tempArray[1])\(day.dayExtension)"
        
    }
    
    func toBool()-> Bool{
        if self == "0"{
            return false
        }else{
            return true
        }
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}

extension Int{
    
    var dayExtension: String{
        if self == 1 || self == 21 || self == 31 {
            return "st"
        }else if self == 2 || self == 22{
            return "nd"
        }else if self == 3 || self == 23{
            return "rd"
        }else{
            return "th"
        }
    }
    
}

extension Date{
    
    func getTimeStringToDate() -> String {
      
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        let convertedTime: String = dateFormatter.string(from: self)
        return convertedTime
    }
    
    func getFormattedMonthStringToDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMM d"
        let convertedTime: String = dateFormatter.string(from: self)
        return convertedTime
    }
    
    func getDateString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let convertedTime: String = dateFormatter.string(from: self)
        return convertedTime
    }
    
    func getCurrentDateString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let convertedTime: String = dateFormatter.string(from: self)
        return convertedTime
    }
    
    func getDateWithDDMMMYYYYHHMMAFormat() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
        let convertedTime: String = dateFormatter.string(from: self)
        return convertedTime
    }
    
    func getDateStringWithHHAFormat() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        let convertedTime: String = dateFormatter.string(from: self)
        return convertedTime
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
    func getDayNameWithDate() -> String {
       
        let weekday = Calendar.current.dateComponents([.weekday], from: self).weekday
        switch weekday {
        case 1?:
            return "Sunday"
        case 2?:
            return "Monday"
        case 3?:
            return "Tuesday"
        case 4?:
            return "Wednesday"
        case 5?:
            return "Thursday"
        case 6?:
            return "Friday"
        case 7?:
            return "Saturday"
        default:
            return ""
        }
    }
}
