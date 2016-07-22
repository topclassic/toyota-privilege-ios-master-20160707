//
//  DBManager.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/13/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation

import UIKit

let sharedInstance = DBManager()

class DBManager: NSObject {
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> DBManager{
        if(sharedInstance.database == nil){
            sharedInstance.database = FMDatabase(path: DBUtil.getPath("tprivilege.sqlite"))
        }
        return sharedInstance
    }
    
    /******** Beacon ********/
    
    func getAllBeaconData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM ibeacon ORDER BY updated_date DESC", withArgumentsInArray: nil)
        let mutableArrayBeaconInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let beaconInfo : BeaconInfo = BeaconInfo()
                beaconInfo.id = Int(resultSet.intForColumn("id"))
                beaconInfo.major = Int(resultSet.intForColumn("major"))
                beaconInfo.minor = Int(resultSet.intForColumn("minor"))
                beaconInfo.shop_id = Int(resultSet.intForColumn("shop_id"))
                beaconInfo.shop_name = resultSet.stringForColumn("shop_name")
                beaconInfo.shop_noti_title = resultSet.stringForColumn("shop_noti_title")
                beaconInfo.shop_noti_detail = resultSet.stringForColumn("shop_noti_detail")
                beaconInfo.is_read = resultSet.boolForColumn("is_read")
                beaconInfo.version = Int(resultSet.intForColumn("version"))
                beaconInfo.count = Int(resultSet.intForColumn("count"))
                mutableArrayBeaconInfo.addObject(beaconInfo)
            }
        }
        sharedInstance.database!.close()
        return mutableArrayBeaconInfo
    }
    
    func insertNewBeaconData(beaconInfo : BeaconInfo) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO ibeacon (major, minor, shop_id, shop_name, shop_noti_title, shop_noti_detail, created_date, updated_date, is_read, version, count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsInArray: [beaconInfo.major!, beaconInfo.minor!, beaconInfo.shop_id!, beaconInfo.shop_name!, beaconInfo.shop_noti_title!, beaconInfo.shop_noti_detail!, NSDate(), NSDate(), false, 1, 0])
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updateBeaconData(beaconInfo : BeaconInfo) -> Bool{
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE ibeacon SET updated_date = ? , count = ? WHERE shop_id = ?", withArgumentsInArray: [NSDate(), beaconInfo.count!+1, beaconInfo.shop_id!])
        sharedInstance.database!.close()
        return isUpdated

    }
    
    func updateReadStatusToTrue(shopId : Int) -> Bool{
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE ibeacon SET is_read = ? WHERE shop_id = ?", withArgumentsInArray: [true, shopId])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteBeaconDataFromShopId(shopId: Int) -> Bool{
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("DELETE FROM ibeacon WHERE shop_id = ?", withArgumentsInArray: [shopId])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteAllBeaconData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM ibeacon")
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getShopDataFromShopId(shopId : Int) -> BeaconInfo{
        sharedInstance.database!.open()
        let shopData: BeaconInfo = BeaconInfo()
        let result = sharedInstance.database!.executeQuery("SELECT * FROM ibeacon WHERE shop_id = ?", withArgumentsInArray: [shopId])
        if(result != nil){
            while result.next() {
                shopData.shop_id = Int(result.intForColumn("shop_id"))
                shopData.shop_name = result.stringForColumn("shop_name")
                shopData.shop_noti_title = result.stringForColumn("shop_noti_title")
                shopData.is_active = Int(result.intForColumn("shop_id"))
                shopData.created_date = result.dateForColumn("created_date")
                shopData.updated_date = result.dateForColumn("updated_date")
                shopData.is_read = result.boolForColumn("is_read")
                shopData.version = Int(result.intForColumn("version"))
                shopData.count = Int(result.intForColumn("count"))
            }
        }
        sharedInstance.database!.close()
        return shopData
    }
    
    func getShopIdInDB(major: Int, minor: Int) -> Int{
        sharedInstance.database!.open()
        var shopId : Int = 0
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM ibeacon WHERE major = ? AND minor = ?", withArgumentsInArray: [major, minor])
        if(resultSet != nil){
            while resultSet.next() {
                shopId = Int(resultSet.intForColumn("shop_id"))
                break
            }
        }
        sharedInstance.database!.close()
        return shopId
    }
    
    /******** End Beacon ********/

    
    
    /******** AR ********/
    func getArDataFromArName(arName : String){
        sharedInstance.database!.open()
        let arInfo : ArInfo = ArInfo()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM ar WHERE ar_image_name = ? AND is_active = 1", withArgumentsInArray: [arName])
        if(resultSet != nil){
            while resultSet.next() {
                arInfo.ar_image_name = resultSet.stringForColumn("ar_image_name")
                arInfo.ar_image_path = resultSet.stringForColumn("ar_image_path")
                arInfo.ar_link = resultSet.stringForColumn("ar_link")
                arInfo.ar_related_link = resultSet.stringForColumn("ar_related_link")
                break
            }
        }
        sharedInstance.database!.close()
    }
    
    func getAllArData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM ar WHERE is_active = 1", withArgumentsInArray: nil)
        let mutableArrayArInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let arInfo : ArInfo = ArInfo()
                arInfo.id = Int(resultSet.intForColumn("id"))
                arInfo.ar_image_name = resultSet.stringForColumn("ar_image_name")
                arInfo.ar_image_path = resultSet.stringForColumn("ar_image_path")
                arInfo.ar_link = resultSet.stringForColumn("ar_link")
                arInfo.ar_related_link = resultSet.stringForColumn("ar_related_link")
                mutableArrayArInfo.addObject(arInfo)
            }
        }
        sharedInstance.database!.close()
        return mutableArrayArInfo
    }
    
    func insertNewArData(arInfo : ArInfo) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO ar (ar_image_name, ar_image_path, ar_link, ar_related_link, is_active, created_date ) VALUES (?, ?, ?, ?, ?, ?)", withArgumentsInArray: [arInfo.ar_image_name!, arInfo.ar_image_path!, arInfo.ar_link!, arInfo.ar_related_link!, arInfo.is_active!, NSDate()])
        sharedInstance.database!.close()
        return isInserted
    }
    
    func deleteAllArData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM ar")
        sharedInstance.database!.close()
        return isDeleted
    }
    
    
    
    /******** End AR ********/
    
}