//
//  BeaconViewController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/7/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit


class BeaconViewController: UITableViewController{
    
    struct shopData {
        var shopId:Int?
        var shopNotiTitle:String?
        var shopName:String?
        var shopNotiDetail:String?
        var isRead:Bool?
    }
    
    var data: [shopData] = []
    var shopIdFromNoti : Int?
    var activityIndicator = UIActivityIndicatorView()
    static var bvc : BeaconViewController = BeaconViewController()
    
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BeaconViewController.bvc = self
        setTableView()
        setNavigationBarBackButton()
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if shopIdFromNoti != nil{
            let indexPath = findIndexpathFromShopId(shopIdFromNoti!)
            self.tableview.delegate?.tableView!(self.tableview, didSelectRowAtIndexPath: indexPath)
            shopIdFromNoti = nil
        }
        hideIndicator()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        showIndicator()
        clearDataArray()
        clearTabbarBadgeItem()
        clearTableviewBadge()
        getBeaconHistoryData()
        tableview.reloadData()
    }
    
    func refresh(sender:AnyObject){
        // Updating your data here...
        clearDataArray()
        getBeaconHistoryData()
        tableview.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func forceRefreshFromNoti(){
        showIndicator()
        clearDataArray()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        getBeaconHistoryData()
        tableview.reloadData()
        hideIndicator()
    }
    
    func clearDataArray(){
        data = []
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var numOfSections : Int = 0;
        if (data.count > 0){
            numOfSections = 1;
            tableview.backgroundView = nil;
        }else{
//            let screenWidth = UIScreen.mainScreen().bounds.width
//            let screenHeight = UIScreen.mainScreen().bounds.height
//            let navBarHeight = self.navigationController?.navigationBar.frame.size.height
//            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height

            let label : UILabel = UILabel.init(frame: CGRectMake(0,0, tableview.bounds.size.width, tableview.bounds.size.height))
            label.text = "No iBeacon History"
            label.textColor = UIColor.blackColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: "ThaiSansNeue-SemiBold", size: 40)
//            label.center = self.view.center
//            label.center = CGPoint(x: label.center.x, y: label.center.y - navBarHeight! - statusBarHeight)
            tableview.backgroundView = label
            
        }
        
        return numOfSections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows : Int = data.count > 0 ? data.count : 0
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "Cell", forIndexPath: indexPath) as! BeaconTableViewCell
        if(data.count > 0){
            cell.shopTitle.font = UIFont(name: "ThaiSansNeue-Bold", size: 24)
            cell.shopTitle.text = data[indexPath.row].shopNotiTitle!
            
            cell.shopName.font = UIFont(name: "ThaiSansNeue-Bold", size: 22)
            cell.shopName.text = data[indexPath.row].shopName!
            
            cell.shopDetail.font = UIFont(name: "ThaiSansNeue-SemiBold", size: 18)
            cell.shopDetail.text = data[indexPath.row].shopNotiDetail!
            
            var shopImg : UIImage = UIImage(named: "AppIcon60x60")!
            
            if let url = NSURL(string: "https://www.toyotaprivilege.com/images/priv_pic/l_\(data[indexPath.row].shopId!).jpg") {
                if let data = NSData(contentsOfURL: url) {
                    shopImg = UIImage(data: data)!
                }
            }
            cell.shopImage.image = shopImg
            let width = cell.shopImage.frame.size.width
            let badgeLabel = createBadgeLabel(width)

            let isRead = data[indexPath.row].isRead!
//            NSLog("shop \(data[indexPath.row].shopName!) is read? => \(isRead)")
            if isRead == false {
                cell.backgroundColor = Util().UIColorFromRGB(0xEFF0F1)
                cell.shopImage.addSubview(badgeLabel)
                
            }else{
                cell.backgroundColor = UIColor.whiteColor()
                for subview in cell.shopImage.subviews {
                    subview.removeFromSuperview()
                }
            }
            
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            let alertController = UIAlertController(title: "Toyota Privilege", message: "คุณต้องการลบข้อมูล \(data[indexPath.row].shopName!) ?", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "ใช่", style: .Default, handler: { action -> Void in
                //delete in db
                self.showIndicator()
                let shopId = self.findShopIdFromIndexPath(indexPath)
                DBManager.getInstance().deleteBeaconDataFromShopId(shopId)
                self.data.removeAtIndex(indexPath.row)
                self.clearDataArray()
                self.getBeaconHistoryData()
                self.tableview.reloadData()
                self.hideIndicator()
            });
            
            let cancelAction = UIAlertAction(title: "ยกเลิก", style: .Cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("beaconWebviewSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "beaconWebviewSegue") {
            if let destinationVC = segue.destinationViewController as? BeaconWebviewViewController {
                var id : Int?
                if(shopIdFromNoti != nil){
                    id = shopIdFromNoti
                }else{
                    let row = self.tableview.indexPathForSelectedRow?.row
                    id = data[row!].shopId
                }
                destinationVC.shopId = id!
                shopIdFromNoti = nil
            }
        }
    }

    
    func setTableView(){
        tableview.tableFooterView = UIView(frame:CGRectZero)
        
    }
    
    func getBeaconHistoryData(){
        let mutableArrayBeaconData : NSMutableArray = DBManager.getInstance().getAllBeaconData()
        for i in 0..<mutableArrayBeaconData.count {
            let beaconRow = mutableArrayBeaconData.objectAtIndex(i) as! BeaconInfo
            data.append(shopData(shopId: beaconRow.shop_id!, shopNotiTitle: beaconRow.shop_noti_title!, shopName: beaconRow.shop_name!, shopNotiDetail: beaconRow.shop_noti_detail!, isRead: beaconRow.is_read!))
        }
    }
    
    func setNavigationBarBackButton(){
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = Util().UIColorFromRGB(0x58585a)
    }
    
    func findIndexpathFromShopId(shopId : Int) -> NSIndexPath{
        var row : Int?
        for (i,shopData) in data.enumerate() {
            if(shopData.shopId == shopIdFromNoti){
                row = i
                break
            }
        }
        return NSIndexPath(forRow: row!, inSection: 0)
    }
    
    func findShopIdFromIndexPath(indexPath: NSIndexPath) -> Int{
        var shopId: Int?
        let row = indexPath.row
        shopId = data[row].shopId
        return shopId!
        
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
    
    func clearTableviewBadge(){
        NSLog("clear Tableview badge")
        Util().userDefaults.setInteger(0, forKey: "tableviewBadge")
    }
    
    func createBadgeLabel(imgWidth: CGFloat) -> UILabel{
        let fontSize: CGFloat = 10
        var digits : CGFloat?
        var width : CGFloat?
        let badge : UILabel = UILabel()
        badge.layer.cornerRadius = (fontSize + 8) / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .Center
        badge.font = UIFont.boldSystemFontOfSize(fontSize)
        badge.textColor = UIColor.whiteColor()
        badge.highlightedTextColor = UIColor.clearColor()
        badge.backgroundColor = Util().UIColorFromRGB(0xE11F27)
        digits = CGFloat( "N".characters.count )
        badge.text = "N"
        width = max((fontSize + 8) , 0.7 * (fontSize + 8) * digits!)
        badge.frame = CGRectMake(imgWidth - width!/2, 0 - (fontSize + 8)/2, width!, (fontSize + 8))
        return badge
    }
    
    func clearTabbarBadgeItem(){
        self.tabBarController?.tabBar.items?.last?.badgeValue = nil
        Util().userDefaults.setInteger(0, forKey: "tabbarBadge")
    }
}


