//
//  GeneralExtensions.swift
//  MeClub
//
//  Created by Probir Chakraborty on 18/07/17.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()

// MARK:- Array Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

//MARK:- UIButton Extension
enum Type : String {
    case vertical
    case horizontal
}

extension UIButton {
    

}

// MARK:- UILabel Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//MARK:- Extension Methods for label
extension UILabel {
    ///Find the index of character (in the attributedText) at point
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
    
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }
    
    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }
    
    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }
    
    class func textWidth(font: UIFont, text: String) -> CGFloat {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(labelSize.width)
    }
    
}

//MARK:- Date Extension
extension Date {
    func getWeekDayFromDay() -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.weekdaySymbols[Calendar.current.component(.weekday, from:self)-1]
    }
    
    func getTimeFromDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: self)
    }
    
    func checkWeekDayORWeekendFromDay() -> String {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 0 || weekday == 6 ? "Weekend" : "WeekDay"
    }
    var millisecondsSince1970:Int {
            return Int((self.timeIntervalSince1970).rounded())
    }
        
    init(milliseconds:Int) {
            self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) yrs ago"   }
        if months(from: date)  > 0 { return "\(months(from: date)) months ago"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) w ago"   }
        if days(from: date)    > 0 { return "\(days(from: date)) d ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date)) hrs ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) mins ago" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) sec ago" }
        return ""
    }
}

// MARK:- UIImageView Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        // check for cache
        if let cachedImage = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix(kImage),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    self.image = #imageLiteral(resourceName: "profile")
                    return
            }
            DispatchQueue.main.async() { () -> Void in
                imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    /*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Changing icon color according to theme <<<<<<<<<<<<<<<<<<<<<<<<*/
    func setColor(_ color:UIColor) {
        
        if let image = self.image {
            var s = image.size // CGSize
            s.height *= image.scale
            s.width *= image.scale
            
            UIGraphicsBeginImageContext(s)
            
            var contextRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: s)
            
            // Retrieve source image and begin image context
            let itemImageSize = s //CGSize
            
            let xVal = (contextRect.size.width - itemImageSize.width)/2
            let yVal = (contextRect.size.height - itemImageSize.height)
            
            //let itemImagePosition = CGPoint(x: ceilf(xFloatVal), y: ceilf(yVal)) //CGPoint
            
            let itemImagePosition = CGPoint(x: xVal, y: yVal) //CGPoint
            
            UIGraphicsBeginImageContext(contextRect.size)
            
            let c = UIGraphicsGetCurrentContext() //CGContextRef
            
            // Setup shadow
            // Setup transparency layer and clip to mask
            c!.beginTransparencyLayer(auxiliaryInfo: nil)
            c!.scaleBy(x: 1.0, y: -1.0)
            
            //CGContextRotateCTM(c, M_1_PI)
            
            c!.clip(to: CGRect(x: itemImagePosition.x, y: -itemImagePosition.y, width: itemImageSize.width, height: -itemImageSize.height), mask: image.cgImage!)
            
            // Fill and end the transparency layer
            let colorSpace = color.cgColor.colorSpace //CGColorSpaceRef
            let model = colorSpace!.model //CGColorSpaceModel
            
            let colors = color.cgColor.components
            
            if (model == .monochrome) {
                c!.setFillColor(red: (colors?[0])!, green: (colors?[0])!, blue: (colors?[0])!, alpha: (colors?[1])!)
            } else {
                c!.setFillColor(red: (colors?[0])!, green: (colors?[1])!, blue: (colors?[2])!, alpha: (colors?[3])!)
            }
            
            contextRect.size.height = -contextRect.size.height
            contextRect.size.height -= 15
            c!.fill(contextRect)
            c!.endTransparencyLayer()
            
            let img = UIGraphicsGetImageFromCurrentImageContext() //UIImage
            
            let img2 = UIImage(cgImage: img!.cgImage!, scale: image.scale, orientation: image.imageOrientation)
            
            UIGraphicsEndImageContext()
            
            self.image = img2
            
        } else {
            logInfo(message: "Unable to chage color of image. Image not found")
        }
    }
}


// MARK:- Dictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Dictionary {
    
    func validatedValue(_ key: Key, expected: AnyObject) -> AnyObject {
        
        // checking if in case object is nil
        
        if let object = self[key] as? AnyObject{
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if (object.isKind(of: expected.classForCoder) == false) {
                //logInfo("case // checking if object is of desired class....not")
                
                return expected
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    //logInfo("null string")
                    return "" as AnyObject
                }
            }
            
            return object
        }
        else {
            
            if expected is String || expected as! String == "" {
                return "" as AnyObject
            }
            
            return expected
        }
    }
    
}

// MARK:- UIColor Extension

extension UIColor {
//    class func appYellowColor() -> UIColor {
//        return RGBA(r: 238, g: 92, b: 48, a: 1)
//    }
    class func appBlueColor() -> UIColor {
        return UIColor(red: 45.0/255.0, green: 195.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
    }
}

// MARK:- NSDictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension NSDictionary {
    
    func toNSData() -> NSData {
        return try! JSONSerialization.data(withJSONObject: self, options: []) as NSData
    }
    
    func toJsonString() -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString
    }
}

// MARK:- UIView Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIView {
    
//    @IBInspectable var borderColor : UIColor {
//        get {
//            return RGBA(r: 64, g: 175, b: 214, a: 1)
//        }
//        set {
//            layer.borderColor = borderColor.cgColor
//        }
//    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    func setBorder(color:UIColor, borderWidth:CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
  
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }
    
    func setShadow(radius: CGFloat) {
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1,height: 1)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.cornerRadius = radius
        
    }
    
    //MARK:- UILAbel Extension
    func drawTextInRect(rect: CGRect) {
        
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        self.drawTextInRect(rect: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    
    
  
    
//// MARK:- UIViewController Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//private var progressHUDTimer: Timer?
//
//extension UIViewController {
//    
//    // TODO: Review both methods below: `showProgressHUD` and `hideProgressHUD`.
//    // There might be a better API design.
//    
//    /// Creates a new HUD, adds it to this view controller view and shows it.
//    /// The counterpart to this method is `hideProgressHUD`.
//    func showProgressHUD(animated animated: Bool = true, whiteColor: Bool = false) {
//        hideProgressHUD(animated: false)
//        /// Grace period is the time (in seconds) that the background operation
//        /// may be run without showing the HUD. If the task finishes before the
//        /// grace time runs out, the HUD will not be shown at all.
//        ///
//        /// This *was* supposed to be done by the `graceTime` property, but it
//        /// doesn't seem to be working at all. So we rolled our own implementation.
//        let graceTime = 0.100
//        progressHUDTimer = Timer.scheduledTimerWithTimeInterval(graceTime) {
//            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: animated)
//            hud.taskInProgress = true
//            hud.graceTime = 0
//            hud.square = true
//            hud.minSize = CGSize(width: 50, height: 50)
//            if whiteColor {
//                hud.color = UIColor.whiteColor()
//                hud.activityIndicatorColor = UIColor.grayColor()
//            }
//        }
//    }
//    
//    /// Finds all the HUD subviews and hides them.
//    func hideProgressHUD(animated animated: Bool = true) {
//        progressHUDTimer?.dispose()
//        progressHUDTimer = nil
//        for hud in MBProgressHUD.allHUDsForView(self.view) as! [MBProgressHUD] {
//            hud.taskInProgress = false
//            hud.hide(true)
//        }
//    }
//
//}
    
    
}

extension CALayer{
    
    func setShadow(radius: CGFloat) {
        
        self.shadowColor = UIColor.darkGray.cgColor
        self.shadowOffset = CGSize(width: 1,height: 1)
        self.shadowRadius = 2.0
        self.shadowOpacity = 0.5
        self.masksToBounds = false
        self.cornerRadius = radius
        
    }
    
}



