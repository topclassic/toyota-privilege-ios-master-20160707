//
//  BeaconInfo.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/13/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation

class BeaconInfo: NSObject {
    var id: Int?
    var major: Int?
    var minor: Int?
    var shop_id: Int?
    var shop_name: String?
    var shop_noti_title: String?
    var shop_noti_detail: String?
    var created_date: NSDate?
    var updated_date: NSDate?
    var is_active: Int?
    var is_read: Bool?
    var version : Int?
    var count : Int?
}