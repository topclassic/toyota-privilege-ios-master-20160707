//
//  HotPrivilegeController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 2/23/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit
import JavaScriptCore


class HotPrivilegeController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate{

    @IBOutlet var webview: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let deviceId : String = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var mobile : String?
    var sid: String?
    var etoid: String?
    var password: String?
    var fbid: String?
    var checkFirstOpen : Bool = true
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func handleOpenURL(notification:NSNotification){
        if let url = notification.object as? NSURL{
//            print("url = \(url)")
//            showAlertTest("in handleOpen", message: url.absoluteString)
            etoid = Util().getQueryStringParameter(url.absoluteString, param: "insdid")!
            
            fbid = Util().getQueryStringParameter(url.absoluteString, param: "fbid")!
//            print("etoid = \(etoid!)")
        }
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "HANDLEOPENURL", object:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get from T-Connect
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HotPrivilegeController.handleOpenURL(_:)), name:"HANDLEOPENURL", object: nil)
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let url = delegate?.openUrl{
            delegate?.openUrl = nil
//            showAlertTest("in didLoad", message: url.absoluteString)
            etoid = Util().getQueryStringParameter(url.absoluteString, param: "insdid")!
            fbid = Util().getQueryStringParameter(url.absoluteString, param: "fbid")!
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true
        
        if(Reachability.isConnectedToNetwork() == false){
            showAlert("No internet connection", message: "Please ensure you are connected to the internet")
            return
        }
        
        webview.scrollView.delegate = self
        
        sid = Util().getCurrentTimestamp()
        if Util().isMobileEmpty(){
            addJsSavePhoneToWebview()
            addJsSaveEtoidToWebview()
            addJsSavePasswordToWebview()
        }else{
            mobile = String(Util().userDefaults.objectForKey("mobile")!)
            loadAddress()
        }
    }
    
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
    

    func addJsSavePhoneToWebview(){
        let ctx:JSContext = webview.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let savePhone: @convention(block) String -> Void = { input in
//            self.showAlertTest("Phone Number", message: input)
            self.mobile = input
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
            //            self.showAlertTest("Phone Number", message: input)
            self.etoid = input
            Util().userDefaults.setObject(input, forKey: "insdid")
            self.sid = Util().getCurrentTimestamp()
//            self.loadAddress()
        }
        
        ctx.setObject(unsafeBitCast(saveEtoid, AnyObject.self), forKeyedSubscript: "saveEtoid")
        loadAddress()
    }
    
    func addJsSavePasswordToWebview(){
        let ctx:JSContext = webview.valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as! JSContext
        
        let savePassword: @convention(block) String -> Void = { input in
            //            self.showAlertTest("Phone Number", message: input)
            self.password = input
            Util().userDefaults.setObject(input, forKey: "password")
            self.sid = Util().getCurrentTimestamp()
//            self.loadAddress()
        }
        
        ctx.setObject(unsafeBitCast(savePassword, AnyObject.self), forKeyedSubscript: "savePassword")
        loadAddress()
    }

    
    func loadAddress(){
        var urlString : String = "https://www.toyotaprivilege.com/privilege_gbook/index.aspx?device_id=\(deviceId)";
        if(sid?.isEmpty == false){
            urlString += "&sid=\(sid!)"
        }
       
        if(mobile?.isEmpty == false){
            urlString += "&mobile=\(mobile!)"
        }else{
            urlString += "&mobile="
            Util().userDefaults.setObject("", forKey: "mobile")
        }
        
        if(etoid?.isEmpty == false){
            urlString += "&insdid=\(etoid!)"
            Util().userDefaults.setObject(etoid, forKey: "etoid")
        }else{
            urlString += "&insdid="
            Util().userDefaults.setObject("", forKey: "etoid")
        }
        
        if(fbid?.isEmpty == false){
            urlString += "&fbid=\(fbid!)"
            Util().userDefaults.setObject(fbid, forKey: "fbid")
        }else{
            urlString += "&fbid="
            Util().userDefaults.setObject("", forKey: "fbid")
        }
        
//        showAlertTest("First Open Url", message: urlString)
//        print("first open url = \(urlString)")
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        webview.loadRequest(request)
        view.addSubview(webview)
        view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        if !checkFirstOpen {
            sid = Util().getCurrentTimestamp()
            loadHotPrivilegeAddress()
        }
        checkFirstOpen = false
        
    }
    
    func loadHotPrivilegeAddress(){
        var urlString : String = String(Util().userDefaults.objectForKey("currentUrl")!)
        if urlString.rangeOfString("&sid") != nil{
            urlString = Util().cutUrlParameter(urlString, paramName: "sid")!
        }

        if urlString.rangeOfString("&request_page") != nil{
            urlString = Util().cutUrlParameter(urlString, paramName: "request_page")!
        }
        
        urlString = "\(urlString)&sid=\(sid!)"
        urlString = "\(urlString)&request_page=hot_privilege"
        Util().userDefaults.setObject(urlString, forKey: "currentUrl")
//        print("Hot priv url = \(urlString)")
        
//        showAlertTest("Hot Privilege Url", message: urlString)
        
        let url = NSURL(string: urlString);
        let request = NSURLRequest(URL: url!);
        webview.loadRequest(request);
        view.addSubview(webview);
        view.addSubview(activityIndicator);

    }
    
    
    func webViewDidStartLoad(_ : UIWebView){
        activityIndicator.startAnimating()
        NSLog("Webview start load")
//        let currentUrl : String = (webview.request?.URL?.absoluteString)!
//        print("current url is \(currentUrl)")
    }
    
    func webViewDidFinishLoad(_ : UIWebView){
        activityIndicator.stopAnimating()
        NSLog("Webview did finish load")
        
        let currentUrl : String = (webview.request?.URL?.absoluteString)!
        Util().userDefaults.setObject(currentUrl, forKey: "currentUrl")
//        print("current url is \(currentUrl)")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
