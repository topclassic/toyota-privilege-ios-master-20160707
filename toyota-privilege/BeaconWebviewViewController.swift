//
//  BeaconWebviewViewController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/8/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore

class BeaconWebviewViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate{

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    let deviceId : String = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var mobile : String?
    var sid: String?
    var etoid: String?
    var fbid: String?
    var url : NSURL?
    var shopId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.scrollView.delegate = self
        
        DBManager.getInstance().updateReadStatusToTrue(shopId!)
        
        if Util().isMobileEmpty() {
            addJsSavePhoneToWebview()
            addJsSaveEtoidToWebview()
            addJsSavePasswordToWebview()
        }
        
        
        loadAddress()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func setUrl() -> NSURL{
        
        let currentUrl = String(Util().userDefaults.objectForKey("currentUrl")!)
        sid = Util().getCurrentTimestamp()
        etoid = String(Util().userDefaults.objectForKey("etoid")!)
        mobile = String(Util().userDefaults.objectForKey("mobile")!)
        fbid = String(Util().userDefaults.objectForKey("fbid")!)
        let priv_type = Util().getQueryStringParameter(currentUrl, param: "priv_type")!
        let cusId = Util().getQueryStringParameter(currentUrl, param: "cus_id")!
        let cusLevel = Util().getQueryStringParameter(currentUrl, param: "cus_level")!
        
        //fix get param from previous url -3-
        var urlString : String = "https://www.toyotaprivilege.com/privilege_gbook/PrivilegeDetail.aspx?priv_type=\(priv_type)&cus_id=\(cusId)&cus_level=\(cusLevel)&device_id=\(deviceId)"
        
//        NSLog("urlString = \(urlString)")
        
        if urlString.rangeOfString("&sid") != nil{
            urlString = Util().cutUrlParameter(urlString, paramName: "sid")!
        }
        
        
        urlString += "&sid=\(sid!)"
        urlString += "&priv_id=\(shopId!)"
    
        if(mobile?.isEmpty == false){
            urlString += "&mobile=\(mobile!)"
        }else{
            urlString += "&mobile="
        }
        
        if(etoid?.isEmpty == false){
            urlString += "&insdid=\(etoid!)"
        }else{
            urlString += "&insdid="
        }
        
        if(fbid?.isEmpty == false){
            urlString += "&fbid=\(fbid!)"
        }else{
            urlString += "&fbid="
        }
        
        
        let tempUrl = NSURL(string: urlString)
//        print("\(urlString)")
        return tempUrl!
        
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
        url = setUrl()
        
        do {
//            let request = NSURLRequest(URL: url!)
//            webview.loadRequest(request)
            var htmlString = try String(contentsOfURL: url!)
            htmlString = addCssForHideHeaderAndSearchbar(htmlString)
            webview.loadHTMLString(htmlString, baseURL: NSURL(string: "https://www.toyotaprivilege.com"))
            view.addSubview(webview)
            view.addSubview(activityIndicator)
            
        } catch let error as NSError {
            print("Error: \(error)")
        }
       
    }
    
    
    func webViewDidStartLoad(_ : UIWebView){
        activityIndicator.startAnimating();
        NSLog("Webview start load")
    }
    
    func webViewDidFinishLoad(_ : UIWebView){
        activityIndicator.stopAnimating();
        NSLog("Webview did finish load")
    }

    func addCssForHideHeaderAndSearchbar(htmlString : String) -> String{
        let cssHtml : String = "<style type=\"text/css\"> #header,#searchbar ,#search-bar, .boxSearch{display:none;} </style></head>"
        let replaceHtmlString = htmlString.stringByReplacingOccurrencesOfString("</head>", withString: cssHtml)
        return replaceHtmlString
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    
    

}