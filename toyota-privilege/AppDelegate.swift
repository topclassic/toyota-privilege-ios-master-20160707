//
//  AppDelegate.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 2/23/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, ESTBeaconManagerDelegate, UITabBarControllerDelegate, CBCentralManagerDelegate{
    
    var openUrl:NSURL?
    var window: UIWindow?
    //Mobile Push
    var kETAppID_Debug: String = "fe33ce02-918e-402d-9a3b-9caa6fc5299b"
    var kETAccessToken_Debug: String = "622qbc9ey45nk2jypa275gcw"
    var kETAppID_Prod: String = "fe33ce02-918e-402d-9a3b-9caa6fc5299b"
    var kETAccessToken_Prod: String = "622qbc9ey45nk2jypa275gcw"
    //
    let locationManager = CLLocationManager()
    let beaconManager = ESTBeaconManager()
    let bluetoothManager = CBCentralManager()
    var shopId : Int?
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
        identifier: "Ranged region")
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let url = url.standardizedURL
        NSNotificationCenter.defaultCenter().postNotificationName("HANDLEOPENURL", object:url!)
        self.openUrl = url
        return true;
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        initGoogleAnalytics()
        askUserToOpenLocationServices()
        initSQLite()
        displayTabbarBadgeIfExist()
        self.bluetoothManager.delegate = self
        self.centralManagerDidUpdateState(bluetoothManager)
        initBeacon()
        if let options = launchOptions{
            let value = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
            
            if let notification = value{
                self.application(application, didReceiveLocalNotification: notification)
                ETPush.pushManager()?.handleLocalNotification(notification)
            }
        }else{
       //     askForNotification(application)
        }
        // Mobile Push
        ETPush.setETLoggerToRequiredState(true)
        do {
            try ETPush.pushManager()!.configureSDKWithAppID(kETAppID_Debug,
                                                            andAccessToken: kETAccessToken_Debug,
                                                            withAnalytics: true,
                                                            andLocationServices: true,
                                                            andProximityServices: false,
                                                            andCloudPages: true,
                                                            withPIAnalytics: true)
        } catch {
            NSLog("Error2: \(error)")
        }
        // Mobile Push
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge , .Sound], categories: nil)
        ETPush.pushManager()?.registerUserNotificationSettings(settings)
        ETPush.pushManager()?.registerForRemoteNotifications()
        ETRegion.retrieveGeofencesFromET()
        ETRegion.retrieveProximityFromET()
        ETPush.pushManager()?.applicationLaunchedWithOptions(launchOptions)
        ETPush.pushManager()?.addAttributeNamed("MyBooleanAttribute", value: "0")
        ETPush.getSDKState()

        //
        return true
    }
    
    func jumpToMobile(application: UIApplication){
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        shopId = 1749
        if(tabBarController.selectedIndex == 5){
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let firstNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("menuNavigation") as! UINavigationController
            tabBarController.viewControllers![5] = firstNavigationController
            firstNavigationController.popToRootViewControllerAnimated(false)
        }else{
            tabBarController.selectedIndex = 5
        }
    }
    //Mobile Push
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        ETPush.pushManager()?.handleNotification(userInfo, forApplicationState: application.applicationState)
        jumpToMobile(application)
           }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings){
        ETPush.pushManager()?.didRegisterUserNotificationSettings(notificationSettings)
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        ETPush.pushManager()?.registerDeviceToken(deviceToken)
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        ETPush.pushManager()?.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
        ETAnalytics.trackPageView("data://applicationDidFailToRegisterForRemoteNotificationsWithError", andTitle: error.localizedDescription, andItem: nil, andSearch: nil)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        ETPush.pushManager()?.handleNotification(userInfo, forApplicationState: application.applicationState)
        jumpToMobile(application)
    }
    //
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        //        application.setMinimumBackgroundFetchInterval(20)
        //        locationManager.startUpdatingLocation()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        application.setMinimumBackgroundFetchInterval(30)
        locationManager.startUpdatingLocation()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        displayTabbarBadgeIfExist()
        
        locationManager.startUpdatingLocation()
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        //        NSLog("\(tabBarController.selectedViewController! )")
        if tabBarController.viewControllers![tabBarController.selectedIndex] is UINavigationController{
            let nav = tabBarController.viewControllers![tabBarController.selectedIndex] as! UINavigationController
            //            NSLog("\(nav.visibleViewController!)")
            
            if nav.visibleViewController is BeaconViewController{
                BeaconViewController.bvc.clearTabbarBadgeItem()
                BeaconViewController.bvc.clearTableviewBadge()
                BeaconViewController.bvc.forceRefreshFromNoti()
            }else if nav.visibleViewController is MenuViewController{
                //add badge in tableview cell
                MenuViewController.mvc.tableview.reloadData()
            }
            
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        shopId = nil
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        askToOpenBluetooth()
    }
    
    func askToOpenBluetooth(){
        if Util().userDefaults.boolForKey("openedBluetoothDialog") == false {
            if(bluetoothManager.state == .PoweredOff){
                let alert = UIAlertController(title: "TOYOTA Privilege", message: "กรุณาเปิดใช้งาน Bluetooth เพื่อให้สามารถใช้งาน Application ได้อย่างมีประสิทธิภาพสูงสุด ", preferredStyle: UIAlertControllerStyle.Alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
                    let settingsUrl = NSURL(string: "prefs:root=Bluetooth")
                    if let url = settingsUrl {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alert.addAction(settingsAction)
                alert.addAction(UIAlertAction(title: "ปิด", style: UIAlertActionStyle.Default, handler: nil))
                Util().userDefaults.setBool(true, forKey: "openedBluetoothDialog")
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                
            }else if(bluetoothManager.state == .PoweredOn){
                
            }
        }
    }
    
    func askUserToOpenLocationServices(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
            
        } else {
            // Fallback on earlier versions
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func initSQLite(){
        DBUtil.copyFile("tprivilege.sqlite")
    }
    
    func initBeacon(){
        NSLog("in initBeacon")
        beaconManager.delegate = self
        beaconManager.requestAlwaysAuthorization()
        beaconManager.startMonitoringForRegion(beaconRegion)
    }
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        NSLog("in didEnterRegion")
        self.beaconManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        //        self.beaconManager.stopMonitoringForRegion(beaconRegion)
        NSLog("in didExitRegion")
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon],
                       inRegion region: CLBeaconRegion) {
        NSLog("in beaconManager didRangeBeacons")
        if let nearestBeacon = beacons.first {
            let tracker = GAI.sharedInstance().trackerWithTrackingId("UA-79398664-1")
            let major = nearestBeacon.major as Int
            let minor = nearestBeacon.minor as Int
            let notification = UILocalNotification()
            var beaconInfo : BeaconInfo = BeaconInfo()
            var shopId : Int?
            ETPush.pushManager()?.handleLocalNotification(notification)
            NSLog("major = \(major), minor = \(minor)")
            
            //get from web
            let jsonData : JSON = getShopDataFromJSON(major, minor: minor)
            if jsonData != nil{
                beaconInfo = parseJSON(jsonData)
                let isActive = beaconInfo.is_active!
                //                let versionFromService = beaconInfo.version!
                
                if(isActive == 1){
                    tracker.send(GAIDictionaryBuilder.createEventWithCategory("Notification", action: "sent", label: "\(beaconInfo.shop_name!)", value: shopId).build() as [NSObject: AnyObject])
                    var pushNotification : Bool = true
                    shopId = DBManager.getInstance().getShopIdInDB(major, minor: minor)
                    var isInDB = false
                    //find shop_id in DB
                    if(shopId! > 0){
                        isInDB = true
                        beaconInfo = DBManager.getInstance().getShopDataFromShopId(shopId!)
                        //                        let versionFromDB = beaconInfo.version
                        let isRead = beaconInfo.is_read!
                        let count = beaconInfo.count!
                        let diffWithUpdatedDate = Util().compareMinute(NSDate(), dbDate: beaconInfo.updated_date!) //for test
                        //                      let diffWithUpdatedDate = Util().compareDay(NSDate(), dbDate: beaconInfo.updated_date!)
                        
                        //                        NSLog("current = \(NSDate())")
                        //                        NSLog("beaconInfo.updated_date! = \(beaconInfo.updated_date!)")
                        
                        //                        NSLog("diffWithCreatedDate = \(diffWithCreatedDate) min")
                        
                        //                        let oneDay = 1
                        //                        let twomin = 2
                        let period = 1
                        if isRead {
                            NSLog("isRead = \(isRead)")
                            NSLog("Didn't push noti beacause it's already read")
                            pushNotification = false
                        }else if count >= 3  {
                            NSLog("count = \(count)")
                            NSLog("Didn't push noti beacause this beacon already pushed 3 notifications")
                            pushNotification = false
                        }else if diffWithUpdatedDate < period{
                            //                            let hour = Util().compareHours(NSDate(), dbDate: beaconInfo.updated_date!)
                            //                            NSLog("diffWithUpdatedDate = \(diffWithUpdatedDate) day => \(hour) hours")
                            //                            NSLog("diffWithUpdatedDate = \(diffWithUpdatedDate) min")
                            
                            NSLog("Didn't push noti beacause it still in period")
                            pushNotification = false
                        }
                    }else{
                        DBManager.getInstance().insertNewBeaconData(beaconInfo)
                        beaconInfo.count = 0
                    }
                    
                    if(pushNotification){
                        NSLog("go push noti => \(NSDate())")
                        DBManager.getInstance().updateBeaconData(beaconInfo)
                        let shopName : String = beaconInfo.shop_name!
                        let shopNotiTitle : String = beaconInfo.shop_noti_title!
                        let shopId : Int = beaconInfo.shop_id!
                        notification.alertBody = shopNotiTitle
                        notification.hasAction = true
                        notification.alertAction = "View"
                        
                        var currentTabbarBadge = Util().userDefaults.integerForKey("tabbarBadge")
                        var currentTableviewBadge = Util().userDefaults.integerForKey("tableviewBadge")
                        var appBadge = UIApplication.sharedApplication().applicationIconBadgeNumber
                        if isInDB == false{
                            currentTabbarBadge += 1
                            currentTableviewBadge += 1
                            appBadge += 1
                        }
                        Util().userDefaults.setInteger(currentTableviewBadge, forKey: "tableviewBadge")
                        Util().userDefaults.setInteger(currentTabbarBadge, forKey: "tabbarBadge")
                        
                        notification.applicationIconBadgeNumber = appBadge
                        notification.soundName = UILocalNotificationDefaultSoundName
                        notification.userInfo = [ "shop_id" : shopId , "major" : major, "minor" : minor, "shop_name" : shopName]
                        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                        
                        tracker.send(GAIDictionaryBuilder.createEventWithCategory("Notification", action: "received", label: "\(shopName)", value: shopId).build() as [NSObject: AnyObject])
                    }
                }
            }
        }
    }
    
    
    //func askForNotification(application: UIApplication) {
        // let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        //application.registerUserNotificationSettings(settings)
  //  }
    func openTConnect(){
        let etoid = String(Util().userDefaults.objectForKey("etoid")!)
        var url : NSURL?
        if(etoid != ""){
            url  = NSURL(string: "https://www.toyotaprivilege.com");
        }else{
            url  = NSURL(string: "https://www.toyotaprivilege.com");
        }
        if UIApplication.sharedApplication().canOpenURL(url!) == true{
            UIApplication.sharedApplication().openURL(url!)
        }else{
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.toyotaprivilege.com")!)
        }
    }
    
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        ETPush.pushManager()?.handleLocalNotification(notification)
        shopId = nil
        
        jumpToMobile(application)
        
        if ( application.applicationState == .Inactive || application.applicationState == .Background  ){
            
            let shop_id = notification.userInfo!["shop_id"] as? Int
            let shop_name = notification.userInfo!["shop_name"] as? String
            if shop_id != nil {
                let tracker = GAI.sharedInstance().trackerWithTrackingId("UA-79398664-1")
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("Notification", action: "clicked", label: "\(shop_name!)", value: shop_id!).build() as [NSObject: AnyObject])
                
               // jumpToBeacon(application, shop_id: shop_id!)
               
            }
        }else{
            NSLog("got noti from beacon")
            let tabBarController = self.window?.rootViewController as! UITabBarController
            NSLog("\(tabBarController.selectedViewController! )")
            if tabBarController.viewControllers![tabBarController.selectedIndex] is UINavigationController{
                let nav = tabBarController.viewControllers![tabBarController.selectedIndex] as! UINavigationController
                //                NSLog("\(nav.visibleViewController!)")
                
                if nav.visibleViewController is BeaconViewController{
                    BeaconViewController.bvc.clearTabbarBadgeItem()
                    BeaconViewController.bvc.clearTableviewBadge()
                    BeaconViewController.bvc.forceRefreshFromNoti()
                }else if nav.visibleViewController is MenuViewController{
                    //add badge in tableview cell
                    MenuViewController.mvc.clearTabbarBadgeItem()
                    MenuViewController.mvc.tableview.reloadData()
                }
                
            }else{
                let currentTabbarBadge = Util().userDefaults.integerForKey("tabbarBadge")
                tabBarController.tabBar.items!.last?.badgeValue = "\(currentTabbarBadge)"
            }
        }
    }
    
    func getShopDataFromJSON(major : Int, minor : Int) -> JSON{
        let urlToRequest : String = "http://toyotaprivilegedev.azurewebsites.net/tprivilege_p3_service/?mode=ibeacon&major=\(major)&minor=\(minor)"
        let url = NSURL(string: urlToRequest)
        
        do{
            let data = try NSData(contentsOfURL: url!, options: [])
            let jsonData = JSON(data: data)
            return jsonData
        }catch _ {
            //            NSLog("catch jaaaa")
            return nil
        }
    }
    
    func parseJSON(json: JSON) -> BeaconInfo{
        let beaconInfo : BeaconInfo = BeaconInfo()
        let status : String = json["status"].stringValue
        if(status == "success"){
            let beacon = json["db"]
            beaconInfo.shop_id = beacon["shop_id"].intValue
            beaconInfo.shop_name = beacon["shop_name"].stringValue
            beaconInfo.shop_noti_title = beacon["shop_noti_title"].stringValue
            beaconInfo.shop_noti_detail = beacon["shop_noti_detail"].stringValue
            beaconInfo.major = beacon["major"].intValue
            beaconInfo.minor = beacon["minor"].intValue
            beaconInfo.is_active = beacon["is_active"].intValue
        }else{
            beaconInfo.is_active = 0
        }
        return beaconInfo
    }
    
    func jumpToBeacon(application: UIApplication, shop_id : Int){
        
        let tabBarController = self.window?.rootViewController as! UITabBarController
        shopId = shop_id
        if(tabBarController.selectedIndex == 4){
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let firstNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("menuNavigation") as! UINavigationController
            tabBarController.viewControllers![4] = firstNavigationController
            firstNavigationController.popToRootViewControllerAnimated(false)
        }else{
            tabBarController.selectedIndex = 4
        }
    }
    
    func initGoogleAnalytics(){
        let tracker = GAI.sharedInstance().trackerWithTrackingId("UA-79398664-1")
        tracker.set(kGAIScreenName, value: "init")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
    }
    
    func displayTabbarBadgeIfExist(){
        let tabBarController = self.window?.rootViewController as! UITabBarController
        let currentTabbarBadge = Util().userDefaults.integerForKey("tabbarBadge")
        if currentTabbarBadge > 0{
            tabBarController.tabBar.items!.last?.badgeValue = "\(currentTabbarBadge)"
            //            tabBarController.tabBar.items!.last?.badgeValue = "N"
        }
    }
    
}

