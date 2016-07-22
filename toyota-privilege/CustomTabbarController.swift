//
//  CustomTabbarController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 3/1/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

class CustomTabbarController: UITabBarController, UITabBarControllerDelegate {

    var centerButton: UIButton?
    var centerImage: UIImageView?
    
    var isOpenMenu: Bool = false
    
    var tconnectButton: UIButton?
    var tconnectImage: UIImageView?
    
    var arButton: UIButton?
    var beaconButton: UIButton?
    var onlineRadioButton: UIButton?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = self;
        
        //prevent button transparent ( show tab bar border top in buttin image)
        let tabbar = UITabBarController().tabBar
        tabbar.barTintColor = UIColor.blackColor()
//        let tabbarBg = UIImage(named: "tabbar") as UIImage?
//        tabbar.backgroundImage = tabbarBg
        UITabBar.appearance().backgroundColor = UIColor.whiteColor()
//        UITabBar.appearance().backgroundImage = tabbarBg
//        UITabBar.appearance().shadowImage = UIImage()
        
       
        self.tabBar.tintColor = UIColor.whiteColor()
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        // set red as selected background color
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabbar.frame.width / numberOfItems, height: tabbar.frame.height)
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageWithColor(Util().UIColorFromRGB(0xe01f26), size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        //set background width & position
        UITabBar.appearance().frame.size.width = self.view.frame.width + 4
        UITabBar.appearance().frame.origin.x = -2
        UITabBar.appearance().frame.origin.y = self.view.frame.height - tabbar.frame.height

        
//        createTConnectButton()
//        createArButton()
//        createBeaconButton()
//        createOnlineRadioButton()
//        
//        createCenterButton()
        
    }
    
   

    func centerButtonPressed(sender: UIButton!) {
        if(!isOpenMenu){
            showMenu()
            isOpenMenu = true
        }else{
            hideMenu()
            isOpenMenu = false
        }
       
    }
    
    func createCenterButton(){
        let rect :CGRect = self.tabBar.bounds
        if( Int(rect.size.width) == 0 || Int(rect.size.height) == 0){
            return
        }
        
        if(centerButton == nil){
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            button.setTitle("", forState: .Normal)
            button.opaque = true
            self.tabBar.addSubview(button)
            centerButton = button
        }
        let image = UIImage(named: "tab_gift") as UIImage?
        centerButton!.setImage(image, forState: .Normal)
        centerButton!.setTitle("", forState: .Normal)
        let btnHeight :CGFloat = rect.size.height
        centerButton!.frame = CGRectMake(rect.size.width*0.5 - (btnHeight/2), btnHeight*0.05, btnHeight*0.9, btnHeight*0.9)
        centerButton?.addTarget(self, action: #selector(self.centerButtonPressed(_:)), forControlEvents: .TouchDown)
        
    }
    
    
    func createTConnectButton(){
        if(tconnectButton == nil){
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            button.setTitle("", forState: .Normal)
            button.opaque = true
            self.view.addSubview(button)
            tconnectButton = button
        }
        let tabbarRect :CGRect = self.tabBar.bounds
        let viewRect :CGRect = self.view.bounds
        let image = UIImage(named: "tab_TC") as UIImage?
        tconnectButton!.setImage(image, forState: .Normal)
        tconnectButton!.setTitle("", forState: .Normal)
        let btnHeight :CGFloat = tabbarRect.size.height

        tconnectButton!.frame = CGRectMake(viewRect.size.width*0.5 - (btnHeight/2), viewRect.size.height - tabbarRect.size.height, btnHeight*0.9, btnHeight*0.9)
        tconnectButton?.addTarget(self, action: #selector(self.tconnectButtonPressed(_:)), forControlEvents: .TouchDown)
        tconnectButton?.backgroundColor = UIColor.blackColor()
        tconnectButton?.alpha = 0.0
        
    }
    
    func createArButton(){
        if(arButton == nil){
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            button.setTitle("", forState: .Normal)
            button.opaque = true
            self.view.addSubview(button)
            arButton = button
        }
        let tabbarRect :CGRect = self.tabBar.bounds
        let viewRect :CGRect = self.view.bounds
        arButton!.setTitle("AR", forState: .Normal)
        let btnHeight :CGFloat = tabbarRect.size.height
        
        arButton!.frame = CGRectMake(viewRect.size.width*0.5 - (btnHeight/2), viewRect.size.height - tabbarRect.size.height, btnHeight*0.9, btnHeight*0.9)
        arButton?.addTarget(self, action: #selector(self.arButtonPressed(_:)), forControlEvents: .TouchDown)
        arButton?.backgroundColor = UIColor.blackColor()
        arButton?.alpha = 0.0
        
    }
    
    func createBeaconButton(){
        if(beaconButton == nil){
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            button.setTitle("", forState: .Normal)
            button.opaque = true
            self.view.addSubview(button)
            beaconButton = button
        }
        let tabbarRect :CGRect = self.tabBar.bounds
        let viewRect :CGRect = self.view.bounds
        beaconButton!.setTitle("B", forState: .Normal)
        let btnHeight :CGFloat = tabbarRect.size.height
        
        beaconButton!.frame = CGRectMake(viewRect.size.width*0.5 - (btnHeight/2), viewRect.size.height - tabbarRect.size.height, btnHeight*0.9, btnHeight*0.9)
        beaconButton?.addTarget(self, action: #selector(self.beaconButtonPressed(_:)), forControlEvents: .TouchDown)
        beaconButton?.backgroundColor = UIColor.blackColor()
        beaconButton?.alpha = 0.0
        
    }
    
    func createOnlineRadioButton(){
        if(onlineRadioButton == nil){
            let button   = UIButton(type: UIButtonType.Custom) as UIButton
            button.setTitle("", forState: .Normal)
            button.opaque = true
            self.view.addSubview(button)
            onlineRadioButton = button
        }
        let tabbarRect :CGRect = self.tabBar.bounds
        let viewRect :CGRect = self.view.bounds
        onlineRadioButton!.setTitle("R", forState: .Normal)
        let btnHeight :CGFloat = tabbarRect.size.height
        
        onlineRadioButton!.frame = CGRectMake(viewRect.size.width*0.5 - (btnHeight/2), viewRect.size.height - tabbarRect.size.height, btnHeight*0.9, btnHeight*0.9)
        onlineRadioButton?.addTarget(self, action: #selector(self.onlineRadioButtonPressed(_:)), forControlEvents: .TouchDown)
        onlineRadioButton?.backgroundColor = UIColor.blackColor()
        onlineRadioButton?.alpha = 0.0
        
    }


    
    func showMenu(){
        showTConnectButton()
        showArButton()
        showBeaconButton()
        showOnlineRadioButton()
    }
    
    func hideMenu(){
        hideTConnectButton()
        hideArButton()
        hideBeaconButton()
        hideOnlineRadioButton()
    }
    
    func showTConnectButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.tconnectButton?.alpha = 1.0
            self.tconnectButton!.frame = CGRectMake(self.tconnectButton!.frame.origin.x + 90, self.tconnectButton!.frame.origin.y - 60, self.tconnectButton!.frame.size.width, self.tconnectButton!.frame.size.height)
        })
    }
    
    
    func showArButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.arButton?.alpha = 1.0
            self.arButton!.frame = CGRectMake(self.arButton!.frame.origin.x - 90, self.arButton!.frame.origin.y - 60, self.arButton!.frame.size.width, self.arButton!.frame.size.height)
        })
    }
    
    func showBeaconButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.beaconButton?.alpha = 1.0
            self.beaconButton!.frame = CGRectMake(self.beaconButton!.frame.origin.x + 35, self.beaconButton!.frame.origin.y - 110, self.beaconButton!.frame.size.width, self.beaconButton!.frame.size.height)
        })
    }
    
    func showOnlineRadioButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.onlineRadioButton?.alpha = 1.0
            self.onlineRadioButton!.frame = CGRectMake(self.onlineRadioButton!.frame.origin.x - 35, self.onlineRadioButton!.frame.origin.y - 110, self.onlineRadioButton!.frame.size.width, self.onlineRadioButton!.frame.size.height)
        })
    }


    
    func hideTConnectButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.tconnectButton!.frame = CGRectMake(self.tconnectButton!.frame.origin.x - 90, self.tconnectButton!.frame.origin.y + 60, self.tconnectButton!.frame.size.width, self.tconnectButton!.frame.size.height)
            self.tconnectButton?.alpha = 0
        })
        
    }
    
    func hideArButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.arButton!.frame = CGRectMake(self.arButton!.frame.origin.x + 90, self.arButton!.frame.origin.y + 60, self.arButton!.frame.size.width, self.arButton!.frame.size.height)
            self.arButton?.alpha = 0
        })
        
    }
    
    func hideBeaconButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.beaconButton!.frame = CGRectMake(self.beaconButton!.frame.origin.x - 35, self.beaconButton!.frame.origin.y + 110, self.beaconButton!.frame.size.width, self.beaconButton!.frame.size.height)
            self.beaconButton?.alpha = 0
        })
        
    }
    
    func hideOnlineRadioButton(){
        UIView.animateWithDuration(0.3, animations:{
            self.onlineRadioButton!.frame = CGRectMake(self.onlineRadioButton!.frame.origin.x + 35, self.onlineRadioButton!.frame.origin.y + 110, self.onlineRadioButton!.frame.size.width, self.onlineRadioButton!.frame.size.height)
            self.onlineRadioButton?.alpha = 0
        })
        
    }
    
    func tconnectButtonPressed(sender: UIButton!) {
        let url  = NSURL(string: "smartGBOOKTH://"); // Change the URL with your URL Scheme
        if UIApplication.sharedApplication().canOpenURL(url!) == true{
            UIApplication.sharedApplication().openURL(url!)
        }else{
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/th/app/t-connect-th/id575879595?mt=8")!)
        }
    }
    
    func arButtonPressed(sender: UIButton!) {
        self.performSegueWithIdentifier("ArIdentifier", sender: nil)
    }
    
    func beaconButtonPressed(sender: UIButton!) {
        
        
    }
    
    func onlineRadioButtonPressed(sender: UIButton!) {
        
        
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//        NSLog("finishedScanOnce = \(Util().userDefaults.boolForKey("finishedScanOnce"))")
        if tabBarController.selectedIndex == 3 && Util().userDefaults.boolForKey("finishedScanOnce"){
            viewController.viewDidLoad()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
