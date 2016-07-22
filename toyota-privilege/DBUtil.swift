//
//  DB.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/13/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit

class DBUtil: NSObject {
    
    class func getPath(fileName: String) -> String {
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(fileName)
        
        return fileURL.path!
    }
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            
            let documentsURL = NSBundle.mainBundle().resourceURL
            let fromPath = documentsURL!.URLByAppendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItemAtPath(fromPath.path!, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
           
//            let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                NSLog("Error : \(error?.localizedDescription)")
            } else {
                NSLog("Copy database success")
            }
//            alert.delegate = nil
//            alert.addButtonWithTitle("Ok")
//            alert.show()
        }
    }
    
    class func invokeAlertMethod(strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
        let alert: UIAlertView = UIAlertView()
        alert.message = strBody as String
        alert.title = strTitle as String
        alert.delegate = delegate
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
}
