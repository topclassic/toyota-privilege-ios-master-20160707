//
//  CustomAlertView.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 6/21/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import Foundation
import UIKit
import MZFormSheetPresentationController
import MZAppearance



class CustomAlertView: UIViewController {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var alertTitle : UILabel!
    @IBOutlet var alertDetail : UILabel!
    @IBOutlet var closeButton : UIButton!
    @IBOutlet var confirmButton : UIButton!
    @IBOutlet var blurView: UIVisualEffectView!
    
    @IBAction func closeDialog(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openDownloadArDialog(sender: AnyObject) {
        self.dismissViewControllerAnimated(false) {
            dispatch_async(dispatch_get_main_queue(), {
                let screenHeight = UIScreen.mainScreen().bounds.height
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewControllerWithIdentifier("ArDownloadingAlertView") as! ArDownloadingAlertView
                let arDownloadDialog = MZFormSheetPresentationViewController(contentViewController: vc)
                arDownloadDialog.presentationController?.contentViewSize = CGSizeMake(300, 100)
                
                arDownloadDialog.presentationController?.frameConfigurationHandler = { _, currentFrame, _ in
                    return CGRectMake(currentFrame.origin.x, screenHeight/2 - 50, 300, 100)
                };
                
                UIViewController.current?.presentViewController(arDownloadDialog, animated: true, completion: nil)
            })
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true

        confirmButton.layer.borderColor = UIColor.whiteColor().CGColor
        confirmButton.layer.cornerRadius = 24
        confirmButton.layer.borderWidth = 1
        
    }
    
}

extension UIViewController {
    static var current: UIViewController? {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let rootViewController = appDelegate.window!.rootViewController {
                if let presentedViewController = rootViewController.presentedViewController {
                    return presentedViewController.presentedViewController ?? presentedViewController
                }
                return rootViewController
            }
            return nil
        }
    }
}
