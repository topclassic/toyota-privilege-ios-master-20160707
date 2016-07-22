//
//  ArDownloadingAlertView.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/26/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit

class ArDownloadingAlertView: UIViewController, NSURLSessionDownloadDelegate, SSZipArchiveDelegate {
    
    @IBOutlet var nowLoadingLabel : UILabel!
    @IBOutlet var arProgressView: UIProgressView!
    @IBOutlet var arProgressLabel: UILabel?
    @IBOutlet var arFileSizeLabel: UILabel?
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    var arProgressCounter:Int = 0 {
        didSet {
            let fractionalProgress = Float(arProgressCounter) / 100.0
            let animated = arProgressCounter != 0
            
            self.arProgressView!.setProgress(fractionalProgress, animated: animated)
            self.arProgressLabel!.text = ("\(arProgressCounter)%")
        }
    }
    
    var downloadTask: NSURLSessionDownloadTask?
    
    @IBAction func closeDialog(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        NSLog("viewDidLoad")
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        arProgressView.transform = CGAffineTransformScale(arProgressView.transform, 1, 3)
        downloadNewArFset()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("didAppear")
    }
    

    
    func downloadNewArFset(){
        DBManager.getInstance().deleteAllArData()
        
        let arVersion = Util().userDefaults.integerForKey("arVersion")
        let fsetUrl = Util().getFsetUrlFromJSON(arVersion)
//        NSLog("downloadNewArFset fsetUrl = \(fsetUrl)")
        downloadFsetFile(fsetUrl)
        getArJsonAndInsertToSQLite(arVersion)
        createData2FolderAndMarkesDat()
        
    }
    
    
    func getArJsonAndInsertToSQLite(arVersion : Int){
        let urlToRequest : String = "https://toyotaprivilegedev.azurewebsites.net/tprivilege_p3_service/?mode=ar&version=\(arVersion)"
        let url = NSURL(string: urlToRequest)
        let data = try? NSData(contentsOfURL: url!, options: [])
        let json = JSON(data: data!)
        
        //update new version in userdefault
        let currentArServiceDbVersion = Util().getVersionFromArResponseJSON(json)
        Util().userDefaults.setInteger(currentArServiceDbVersion, forKey: "arVersion")
        
        let db = json["db"]
        for arItem in db.arrayValue {
            let arInfo: ArInfo = ArInfo()
            let imageName = arItem["image_path"].stringValue.stringByReplacingOccurrencesOfString("picture/", withString: "")
            let imageNameArray = imageName.componentsSeparatedByString(".")
            arInfo.ar_image_name = imageNameArray[0]
            arInfo.ar_image_path = arItem["image_path"].stringValue
            arInfo.ar_link = arItem["link"].stringValue
            arInfo.ar_related_link = arItem["url_link"].stringValue
            arInfo.is_active = arItem["is_active"].boolValue
            DBManager.getInstance().insertNewArData(arInfo)
        }
        
    }
    
    
    func downloadFsetFile(fsetUrl : String){
        NSLog("in downloadFsetFile")
//        NSLog("fsetUrl = \(fsetUrl)")
        let downloadRequest = NSMutableURLRequest(URL: NSURL(string: fsetUrl)!)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        downloadTask = session.downloadTaskWithRequest(downloadRequest)
        downloadTask!.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        updateProgressViewLabelWithProgress(progress * 100)
        updateProgressViewWith(Float(totalBytesWritten), totalFileSize: Float(totalBytesExpectedToWrite))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        //downloaded finished
        NSLog("in didFinishDownloadingToURL")
        let fileManager = NSFileManager()
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent("DataNFT")
        
        if(Util().checkFolderIsExist(dataPath)){
            Util().deleteAllFilesInFolder(dataPath)
            Util().deleteFolderAtPath(dataPath)
        }else{
            NSLog("Didn't have DataNFT Folder")
        }
        
        //create DataNFT in Directory
        do {
            try fileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            NSLog("create directory failed : \(error.localizedDescription)");
        }
        
        //move downloaded file to directory  => DataNFT/fset.zip
        let destinationURLForFile = NSURL(fileURLWithPath: dataPath.stringByAppendingString("/fset.zip"))
        do{
            try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
        }catch let error as NSError {
            NSLog("move to directory failed : \(error.localizedDescription)");
        }
        
        //for check that really has fset.zip in DataNFT
        let isFsetZipinFolder = Util().enumerateFilesInFolder(dataPath)
        if(isFsetZipinFolder){
            let archivePath = dataPath.stringByAppendingString("/fset.zip")
            SSZipArchive.unzipFileAtPath(archivePath, toDestination:dataPath, delegate:self)
            Util().enumerateFilesInFolder(dataPath)
            Util().deleteSpecificFileInFolder(dataPath)
            Util().enumerateFilesInFolder(dataPath)
            
        }
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        NSLog("in didCompleteWithError")
        if let error = error {
            NSLog("Download failed : \(error)")
        } else {
            NSLog("Download finished")
            self.dismissViewControllerAnimated(false, completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "ดาวน์โหลดข้อมูลเสร็จสิ้น", message: "กดปุ่ม ตกลง เพื่อเข้าใช้งานฟังก์ชั่น AR", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "ตกลง", style: .Default, handler: { action -> Void in
                        
                        self.dismissViewControllerAnimated(false, completion: {
//                            dispatch_async(dispatch_get_main_queue(), {
                            
//                            })
                        })
                        
                        
                        
                        self.openAr()
                    });
                    alertController.addAction(okAction)
                    UIViewController.current!.presentViewController(alertController, animated: true, completion: nil)
                })
            })
        }
    }
    
    
    func updateProgressViewLabelWithProgress(percent: Float) {
        self.arProgressCounter = Int(percent)
    }
    
    func updateProgressViewWith(totalSent: Float, totalFileSize: Float) {
        self.arFileSizeLabel!.text = NSString(format: "%.1f MB / %.1f MB", Util().convertFileSizeToMegabyte(totalSent), Util().convertFileSizeToMegabyte(totalFileSize)) as String
    }
    
    
    
    func createData2FolderAndMarkesDat(){
        let fileManager = NSFileManager()
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent("Data2")
        
        if(Util().checkFolderIsExist(dataPath)){
            Util().deleteAllFilesInFolder(dataPath)
            Util().deleteFolderAtPath(dataPath)
        }else{
            NSLog("Didn't have Data2 Folder")
        }
        
        //create Data2 in Directory
        do {
            try fileManager.createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            
        } catch let error as NSError {
            NSLog("create directory failed : \(error.localizedDescription)");
        }
        NSLog("createFolderData2 completed.")
        createMarkersInData2(dataPath)
        
    }
    
    func createMarkersInData2(data2Path : String){
        
        let file = "markers.dat"
        let content = generateMarkersDatContent()
        
        let path = NSURL(fileURLWithPath: data2Path).URLByAppendingPathComponent(file)
        
        //writing
        do {
            try content.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
        }catch let error as NSError {
            NSLog("createMarkersInData2 failed : \(error.localizedDescription)");
        }
        NSLog("createMarkersInData2 completed.")
    }
    
    func generateMarkersDatContent() -> String{
        let arArray = DBManager.getInstance().getAllArData()
        var content = "# Number of markers\n"
        content += "\(arArray.count)\n"
        content += "# Entries for each marker. Format is:\n"
        content += "#\n"
        content += "# Name of pattern file (relative to this file)\n"
        content += "# Marker type (SINGLE)\n"
        content += "# Marker width in millimetres (floating point number)\n"
        content += "# Optional tokens:\n"
        content += "# FILTER [x]   Enable pose estimate filtering for the preceding marker\n"
        content += "# x (optional) specifies the cutoff frequency. Default\n"
        content += "# value is AR_FILTER_TRANS_MAT_CUTOFF_FREQ_DEFAULT, which\n"
        content += "# at time of writing, equals 5.0.\n"
        content += "# A blank line\n\n"
        
        for i in 0..<arArray.count {
            let arRow = arArray.objectAtIndex(i) as! ArInfo
            content += "../../Documents/DataNFT/asset/\(arRow.ar_image_name!)\n"
            content += "NFT\n"
            content += "FILTER 4.0\n\n"
        }
        
        return content
    }
    
    func openAr(){
        NSLog("\n\n ** go to AR camera ** \n\n")
        MenuViewController.mvc.performSegueWithIdentifier("arSegue", sender: nil)
    }
    
}


