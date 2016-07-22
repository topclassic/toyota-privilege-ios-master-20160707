//
//  ArWebviewController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/20/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit

class ArWebviewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {

    @IBOutlet var webview: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        NSLog("ArWebviewController viewDidLoad")
        webview.scrollView.delegate = self
        loadAddress()
        self.view.addSubview(webview)
        self.view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadAddress(){
        let arArray = DBManager.getInstance().getAllArData()
        let index = Util().userDefaults.integerForKey("arIndexFromArCamera")
        Util().userDefaults.setInteger(0, forKey: "arIndexFromArCamera")
        let arRow = arArray.objectAtIndex(index) as! ArInfo
        NSLog("Read image = \(arRow.ar_image_name!)")
        webview.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, webview.frame.size.width, webview.frame.size.height)
        webview.mediaPlaybackRequiresUserAction = false
        webview.scrollView.bounces = false
        
        let urlString : String = arRow.ar_link!
//        NSLog("url = \(urlString)")
//        let urlString : String = "https://www.youtube.com/watch?v=msJuPgfMuLE"
        
        let url = NSURL(string: "\(urlString)&autoplay=1") //
        let request = NSURLRequest(URL: url!)
        webview.loadRequest(request)
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func setNavigationBar(){
        let width: CGFloat = UIScreen.mainScreen().bounds.width
        var navigationBarImage : UIImage?
        switch width {
        case 375: //iPhone 6, 6s
            navigationBarImage = UIImage(named: "navigation_bar_375")
            break
        case 414: //iPhone 6 Plus, 6s Plus
            navigationBarImage = UIImage(named: "navigation_bar_414")
            break
        default: //iPhone 4, 4s, 5, 5s, SE
            navigationBarImage = UIImage(named: "navigation_bar")
            break
        }
        self.navigationController?.navigationBar.setBackgroundImage(navigationBarImage, forBarMetrics: .Default)
        self.navigationController!.navigationBar.translucent = false
        
        setNavigationBarBackButton()
        
    }
    
    func setNavigationBarBackButton(){
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = Util().UIColorFromRGB(0x58585a)
    }



}
