//
//  Util.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 3/8/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit

class Util: NSObject {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var sid : String?
    
    func isMobileEmpty() -> Bool{
        if(userDefaults.objectForKey("mobile") == nil){
            return true
        }else{
            return false
        }
    }
    
    func getCurrentTimestamp() -> String{
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyyMMddHHmmss"
        sid = formatter.stringFromDate(NSDate())
        return sid!
    }
    
    func parseToTimestamp(date: NSDate) -> String{
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyyMMddHHmmss";
        let defaultTimeZoneStr = formatter.stringFromDate(date)
        
        return defaultTimeZoneStr
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        let url = NSURLComponents(string: url)!
        return
            ((((url.queryItems)! as [NSURLQueryItem])))
                .filter({ (item) in item.name == param }).first?
                .value!
    }
    
    
    func cutUrlParameter(urlString: String,paramName: String) -> String? {
        var newUrlString : String?
        let paramValue : String = getQueryStringParameter(urlString, param: paramName)!
        if paramValue.isEmpty == false {
            newUrlString = urlString.stringByReplacingOccurrencesOfString("&\(paramName)=\(paramValue)", withString: "")
        }else if paramName == "lat" || paramName == "lon"{
            newUrlString = urlString.stringByReplacingOccurrencesOfString("&\(paramName)=\(paramValue)", withString: "")
        }
        return newUrlString
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getUIColorForMenu(i: Int) -> UIColor {
        var color : UIColor?
        switch i {
            case 0: //Scan AR
                color = UIColorFromRGB(0xF37B89)
                break;
            case 1: //iBeacon
                color = UIColorFromRGB(0xEC7D34)
                break;
            case 2: //T-Connect
                color = UIColorFromRGB(0x90D14D)
                break;
            default:
                color = UIColorFromRGB(0xD4D8D9)
                break;
        }
        
        return color!
    }
    
    func getArServiceDbVersion(arVersion : Int) -> Int {
        var currentArServiceDbVersion : Int?
        let urlToRequest : String = "https://toyotaprivilegedev.azurewebsites.net/tprivilege_p3_service/?mode=ar&version=\(arVersion)"
        let url = NSURL(string: urlToRequest)
        let data = try? NSData(contentsOfURL: url!, options: [])
        currentArServiceDbVersion = getVersionFromArResponseJSON(JSON(data: data!))
        return currentArServiceDbVersion!
    }
    
    
    func getVersionFromArResponseJSON(json: JSON) -> Int{
        let currentArServiceDbVersion : Int = Int(json["currentVersion"].intValue)
        return currentArServiceDbVersion
    }
    
    func getFsetUrlFromJSON(arVersion : Int) -> String{
        let urlToRequest : String = "https://toyotaprivilegedev.azurewebsites.net/tprivilege_p3_service/?mode=ar&version=\(arVersion)"
//        NSLog("urlToRequest = \(urlToRequest)")
        let url = NSURL(string: urlToRequest)
        let data = try? NSData(contentsOfURL: url!, options: [])
        let json = JSON(data: data!)
        let fsetUrl = json["assetUrl"].stringValue
        
        return fsetUrl
    }

    
    func checkFolderIsExist(filePath : String) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            return true
        } else {
            return false
        }
    }
    
    func deleteSpecificFileInFolder(path : String){
        let fileManager = NSFileManager.defaultManager()
        let filePath = path.stringByAppendingString("/fset.zip")
        do{
            try fileManager.removeItemAtPath(filePath)
        }catch let error as NSError {
            NSLog("deleteZipFileInFolder failed : \(error.localizedDescription)")
        }
    }
    
    func deleteAllFilesInFolder(path : String){
        let fileManager = NSFileManager.defaultManager()
        
        do{
            let contents = try fileManager.contentsOfDirectoryAtPath(path)
            for fileName in contents {
                let filePath = path.stringByAppendingString("/\(fileName)")
                try fileManager.removeItemAtPath(filePath)
                NSLog("completed deleteAllFilesInFolder")
            }
            
        }catch let error as NSError {
            NSLog("deleteAllFilesInFolder failed : \(error.localizedDescription)")
        }
    }
    
    func deleteFolderAtPath(path : String){
        let fileManager = NSFileManager.defaultManager()
        
        do{
            try fileManager.removeItemAtPath(path)
            NSLog("completed deleteFolderAtPath")
            
        }catch let error as NSError {
            NSLog("deleteFolderAtPath failed : \(error.localizedDescription)");
        }
        
    }
    
    func enumerateFilesInFolder(folderName : String) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        
        do{
            let contents = try fileManager.contentsOfDirectoryAtPath(folderName)
            NSLog("Content of \(folderName) is = \(contents)")
            if(contents.count == 1 && contents[0] == "fset.zip"){
                return true
            }
            
        }catch let error as NSError {
            NSLog("enumerateFilesInFolder failed : \(error.localizedDescription)");
        }
        
        return false
        
    }
    
    func convertFileSizeToMegabyte(size: Float) -> Float {
        return (size / 1024) / 1024
    }
    
    func compareMinute(currentDate : NSDate, dbDate : NSDate) -> Int{
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(.Minute, fromDate: dbDate, toDate: currentDate, options: []) //for test in min
        
        let mins = datecomponenets.minute
        return mins
    }
    
    func compareDay(currentDate : NSDate, dbDate : NSDate) -> Int{
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(.Day, fromDate: dbDate, toDate: currentDate, options: [])
        let day = datecomponenets.day
        return day
    }
    
    func compareHours(currentDate : NSDate, dbDate : NSDate) -> Int{
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(.Hour, fromDate: dbDate, toDate: currentDate, options: [])
        let hour = datecomponenets.hour
        return hour
    }

    
    
}

