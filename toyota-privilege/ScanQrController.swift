//
//  ScamQrController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 2/24/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit
import JavaScriptCore

class ScanQrController: UIViewController{
    
    @IBOutlet var webview: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var checkFirstOpen : Bool = true
    var sid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Reachability.isConnectedToNetwork() == false){
            showAlert("No internet connection", message: "Please ensure you are connected to the internet")
            return
        }
        
        if(Util().userDefaults.boolForKey("finishedScanOnce")){
            Util().userDefaults.setBool(false, forKey: "finishedScanOnce")
            self.performSegueWithIdentifier("ScanQrReader", sender: nil)
            return
        }
        
        if !checkFirstOpen{
            sid = Util().getCurrentTimestamp()
            if Util().isMobileEmpty() {
                addJsSavePhoneToWebview()
//                addJsSaveEtoidToWebview()
//                addJsSavePasswordToWebview()
            }else{
                loadAddress()
            }
        }
        Util().userDefaults.setBool(false, forKey: "afterQrScan")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(Util().userDefaults.boolForKey("cancelScan")){
            tabBarController?.selectedIndex = 0
            Util().userDefaults.setBool(false, forKey: "cancelScan")
            return
        }
        
//        print("afterQrScan = \(userDefaults.boolForKey("afterQrScan"))")
        let isAfterQrScan : Bool = Util().userDefaults.boolForKey("afterQrScan")
        if !isAfterQrScan {
            self.performSegueWithIdentifier("ScanQrReader", sender: nil)
        }else{
            checkFirstOpen = false
            viewDidLoad()
            Util().userDefaults.setBool(true, forKey: "finishedScanOnce")
        }
    }
    
    func addJsSavePhoneToWebview(){
        let ctx:JSContext = webview.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let savePhone: @convention(block) String -> Void = { input in
//            self.showAlertTest("Phone Number", message: input)
            Util().userDefaults.setObject(input, forKey: "mobile")
            self.sid = Util().getCurrentTimestamp()
            self.loadAddress()
        }
        
        ctx.setObject(unsafeBitCast(savePhone, AnyObject.self), forKeyedSubscript: "savePhone")
        loadAddress()
    }
    
    func addJsSaveEtoidToWebview(){
        let ctx:JSContext = webview.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let saveEtoid: @convention(block) String -> Void = { input in
            //self.showAlertTest("Phone Number", message: input)
            Util().userDefaults.setObject(input, forKey: "insdid")
            self.sid = Util().getCurrentTimestamp()
            //self.loadAddress()
        }
        
        ctx.setObject(unsafeBitCast(saveEtoid, AnyObject.self), forKeyedSubscript: "saveEtoid")
        loadAddress()
    }
    
    func addJsSavePasswordToWebview(){
        let ctx:JSContext = webview.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let savePassword: @convention(block) String -> Void = { input in
            //self.showAlertTest("Phone Number", message: input)
            Util().userDefaults.setObject(input, forKey: "password")
            self.sid = Util().getCurrentTimestamp()
            //self.loadAddress()
        }
        
        ctx.setObject(unsafeBitCast(savePassword, AnyObject.self), forKeyedSubscript: "savePassword")
        loadAddress()
    }
    
    func loadAddress(){
        var urlString : String = String(Util().userDefaults.objectForKey("currentUrl")!)
        if urlString.rangeOfString("&sid") != nil{
            urlString = Util().cutUrlParameter(urlString, paramName: "sid")!
        }
        urlString = "\(urlString)&sid=\(sid!)"
        Util().userDefaults.setObject(urlString, forKey: "currentUrl")
//        showAlertTest("Redeem Url", message: urlString)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        webview.loadRequest(request)
        view.addSubview(webview)
        view.addSubview(activityIndicator)
    }

    func webViewDidStartLoad(_ : UIWebView){
        let currentUrl : String = (webview.request?.URL?.absoluteString)!
        print("\(currentUrl)")
        activityIndicator.startAnimating()
        NSLog("Webview start load")
    }
    
    func webViewDidFinishLoad(_ : UIWebView){
        activityIndicator.stopAnimating()
        NSLog("Webview did finish load")
        
        let currentUrl : String = (webview.request?.URL?.absoluteString)!
        Util().userDefaults.setObject(currentUrl, forKey: "currentUrl")
//        print("current Url = \(currentUrl)")
//        showAlertTest("Web Response Url", message: currentUrl)
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "TRY AGAIN", style: .Default, handler: { action -> Void in
            self.viewDidLoad()
        });
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    func showAlertTest(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { action -> Void in
            
        });
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
