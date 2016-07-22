//
//  ArController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 5/23/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ArController: UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setNavigationBarBackButton()
//        let instanceOfCustomObject: ARViewController = ARViewController()
//        instanceOfCustomObject.someProperty = "Test Message"
//        print(instanceOfCustomObject.someProperty)
//        instanceOfCustomObject.someMethod()
        
    }
    
     override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(Util().userDefaults.boolForKey("isClickCancelInArScan")){
            Util().userDefaults.setBool(false, forKey: "isClickCancelInArScan")
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let menuNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("menuNavigation") as! UINavigationController
//            self.tabBarController!.viewControllers![4] = menuNavigationController
//            menuNavigationController.popToRootViewControllerAnimated(false)
            
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            self.performSegueWithIdentifier("arCamera", sender: nil)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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


