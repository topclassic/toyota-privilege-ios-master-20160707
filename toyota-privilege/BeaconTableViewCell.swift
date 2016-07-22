//
//  BeaconTableViewCell.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/8/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit

class BeaconTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var shopTitle: UILabel!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopDetail: UILabel!
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
