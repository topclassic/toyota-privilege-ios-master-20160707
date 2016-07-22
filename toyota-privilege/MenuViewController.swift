//
//  MenuViewController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 5/30/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit
import MZFormSheetPresentationController
import MZAppearance


class MenuViewController: UITableViewController, SSZipArchiveDelegate{
    
    var activityIndicator = UIActivityIndicatorView()
    @IBOutlet var tableview: UITableView!
    let menu = ["Scan AR", "Alert (iBeacon)", "T-Connect"]
    let cellImage = ["menu_icon_ar", "menu_icon_ibeacon", "menu_icon_tconnect"]
    let cellImageActive = ["menu_icon_ar_active", "menu_icon_ibeacon_active", "menu_icon_tconnect_active"]
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var shopIdFromNoti : Int?
    
    
    static var mvc : MenuViewController = MenuViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        MenuViewController.mvc = self
        setNavigationBar()
        setTableView()
        
//        listFonts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showIndicator()
        clearTabbarBadgeItem()
        tableview.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        shopIdFromNoti = appDelegate.shopId
        appDelegate.shopId = nil
        if shopIdFromNoti != nil {
            let indexPath = NSIndexPath(forRow: 1, inSection: 0)
            hideIndicator()
            self.tableview.delegate?.tableView!(self.tableview, didSelectRowAtIndexPath: indexPath)
            shopIdFromNoti = nil
        }
        
        hideIndicator()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
        }
        //cell text
        cell!.textLabel?.text = menu[indexPath.row]
        cell!.textLabel?.font = UIFont.boldSystemFontOfSize(22)
        cell!.textLabel?.textColor = Util().getUIColorForMenu(indexPath.row)
        
        //cell image
        let image : UIImage = UIImage(named: cellImage[indexPath.row])!
        cell!.imageView!.image = image
        cell!.imageView?.highlightedImage = UIImage(named: cellImageActive[indexPath.row])!
        
        //when highlighted
        cell!.textLabel?.highlightedTextColor = UIColor.whiteColor()
        let backgroundView = UIView()
        backgroundView.backgroundColor = Util().getUIColorForMenu(indexPath.row)
        cell!.selectedBackgroundView = backgroundView
        cell!.textLabel?.tintColor = UIColor.whiteColor()
        
        cell!.accessoryView = nil
        
        //iBeacon
        let tableviewBadgeNumber : Int = Util().userDefaults.integerForKey("tableviewBadge")
        if indexPath.row == 1 && tableviewBadgeNumber > 0 {
            cell!.accessoryView = createAccessoryViewBadge(indexPath, tableviewBadgeNumber: tableviewBadgeNumber)
        }
        
        return cell!
    }
    
    func createAccessoryViewBadge(indexPath : NSIndexPath, tableviewBadgeNumber : Int) -> UILabel{
        let fontSize: CGFloat = 14
        var digits : CGFloat?
        var width : CGFloat?
        let badge : UILabel = UILabel()
        badge.layer.cornerRadius = (fontSize + 8) / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .Center
        badge.font = UIFont.boldSystemFontOfSize(fontSize)
        badge.textColor = UIColor.whiteColor()
        badge.backgroundColor = Util().UIColorFromRGB(0xE11F27)
        badge.highlightedTextColor = Util().getUIColorForMenu(indexPath.row)
//        badge.text = "N"
//        digits = CGFloat( "N".characters.count )
        
        NSLog("tableviewBadgeNumber = \(tableviewBadgeNumber)")
        
       if tableviewBadgeNumber > 0 {
            digits = CGFloat( "\(tableviewBadgeNumber)".characters.count ) // digits in the label
            badge.text = "\(tableviewBadgeNumber)"
        }
        width = max((fontSize + 8) , 0.7 * (fontSize + 8) * digits!)
        badge.frame = CGRectMake(0, 0, width!, (fontSize + 8))
        
        return badge
    }

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let clickMenu = menu[row]
        switch clickMenu {
            case "Scan AR":
                checkArDB()
                tableview.deselectRowAtIndexPath(indexPath, animated: true)
                break
            case "Alert (iBeacon)":
                openBeaconViewController()
                clearTableviewBadge()
                tableview.deselectRowAtIndexPath(indexPath, animated: true)
                break
            case "T-Connect":
                openTConnect()
                tableview.deselectRowAtIndexPath(indexPath, animated: true)
                break
            default:
                break
        }
    }
    
    func checkArDB(){
        //check ar DB version between sharepreferencs and server
        let arVersion = Util().userDefaults.integerForKey("arVersion")
        let currentArServiceDbVersion = Util().getArServiceDbVersion(arVersion)
//        let currentArServiceDbVersion = 2
        
//        NSLog("arVersion = \(arVersion)")
//        NSLog("currentArServiceDbVersion = \(currentArServiceDbVersion)")
        if(currentArServiceDbVersion == 0){ //same version
            openAr()
        }else{
            requestToDownloadDBAlert()
        }
    }
    
    func requestToDownloadDBAlert(){

//        let margin:CGFloat = 20.0
//        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
//        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
//        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("askToDownloadAR") as! UINavigationController
        let askToDownloadARController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        askToDownloadARController.presentationController?.contentViewSize = CGSizeMake(300, 300)
        
        askToDownloadARController.presentationController?.frameConfigurationHandler = { _, currentFrame, _ in
            return CGRectMake(currentFrame.origin.x, screenHeight/2 - 150, 300, 300)
        };

        askToDownloadARController.presentationController?.shouldDismissOnBackgroundViewTap = true
        askToDownloadARController.presentationController?.shouldCenterVertically = true
        askToDownloadARController.presentationController?.shouldCenterHorizontally = true
        self.presentViewController(askToDownloadARController, animated: true, completion: nil)
    }
    
    func openAr(){
        NSLog("\n\n ** go to AR camera ** \n\n")
        self.performSegueWithIdentifier("arSegue", sender: nil)
    }
    
    
    func openTConnect(){
        let etoid = String(Util().userDefaults.objectForKey("etoid")!)
        var url : NSURL?
        if(etoid != ""){
            url  = NSURL(string: "smartGBOOKTH://etoid=\(etoid)");
        }else{
            url  = NSURL(string: "smartGBOOKTH://");
        }
        if UIApplication.sharedApplication().canOpenURL(url!) == true{
            UIApplication.sharedApplication().openURL(url!)
        }else{
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/th/app/t-connect-th/id575879595?mt=8")!)
        }
    }
    
    func openBeaconViewController(){
        self.performSegueWithIdentifier("beaconSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "beaconSegue") {
            if let destinationVC = segue.destinationViewController as? BeaconViewController {
                var id : Int?
                if(shopIdFromNoti != nil){
                    id = shopIdFromNoti
                    destinationVC.shopIdFromNoti = id!
                    shopIdFromNoti = nil
                }
            }
        }
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
    
    func setTableView(){
        tableview.delegate = self
        tableview.alwaysBounceVertical = false
        tableview.tableFooterView = UIView(frame:CGRectZero)
        tableview.separatorColor = UIColor.clearColor()
        setTableViewBackgroundView()
    }
    
    func setTableViewBackgroundView(){
        let height: CGFloat = UIScreen.mainScreen().bounds.height
        var backgroundImage : UIImage?
        switch height {
        case 667: //iPhone 6, 6s
            backgroundImage = UIImage(named: "menu_background_1334")
            break
        case 736: //iPhone 6 Plus, 6s Plus
            backgroundImage = UIImage(named: "menu_background_2208")
            break
        case 568: //5, 5s, SE
            backgroundImage = UIImage(named: "menu_background_1136")
            break
        default: //iPhone 4, 4s
            backgroundImage = UIImage(named: "menu_background")
            break
        }

        tableview.backgroundView = UIImageView(image: backgroundImage)
    }
    
    func listFonts(){
        for name in UIFont.familyNames(){
            print(name)
            print(UIFont.fontNamesForFamilyName(name))
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func showIndicator(){
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
    
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = self.activityIndicator.tintColor
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: screenWidth/2, y: screenHeight/2 - navBarHeight! - statusBarHeight)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    func hideIndicator(){
        activityIndicator.stopAnimating()
    }
    
    func closeCustomViewDialog(sender: UIButton!){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func clearTabbarBadgeItem(){
        self.tabBarController?.tabBar.items?.last?.badgeValue = nil
        Util().userDefaults.setInteger(0, forKey: "tabbarBadge")
    }
    
    func clearTableviewBadge(){
        Util().userDefaults.setInteger(0, forKey: "tableviewBadge")
    }

}