//
//  scanQrViewController.swift
//  toyota-privilege
//
//  Created by เฮียกวง on 3/2/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class QrReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var previewView: UIView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?
    let locationManager = CLLocationManager()

    @IBAction func closeQrReader(sender: AnyObject) {
        Util().userDefaults.setBool(true, forKey: "cancelScan")
        dismissViewControllerAnimated(true, completion: {})
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Please Scan QR Code";
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        let titleAttributes = [  NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.whiteColor() ];
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes;
        view.backgroundColor = UIColor.blackColor()
  
        
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = UIScreen.mainScreen().bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(previewLayer);
        captureSession.startRunning();
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
            qrCodeFrameView.layer.borderWidth = 2
            previewView.addSubview(qrCodeFrameView)
            previewView.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "TRY AGAIN", style: .Default, handler: { action -> Void in
            self.qrCodeFrameView?.frame = CGRectZero;
            self.captureSession.startRunning();
        });
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func showAlertTest(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "CONTINUE", style: .Default, handler: { action -> Void in
            Util().userDefaults.setBool(true, forKey: "afterQrScan")
            self.dismissViewControllerAnimated(true, completion: {})

        });
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func showAlertPermission(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { action -> Void in
            Util().userDefaults.setBool(true, forKey: "cancelScan")
            self.dismissViewControllerAnimated(true, completion: {})
            //UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!) //warp to application settings
        });
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkCameraPermission()
        if (captureSession?.running == false) {
            captureSession.startRunning();
        }
    }
    
    func checkCameraPermission(){
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ==  AVAuthorizationStatus.Authorized{
            // Already Authorized
            print("Camera : Authorized")
            
        }else{
            print("Camera : else")
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == false{
                    // User rejected
                    self.showAlertPermission("Privacy Camera Access", message: "Please turn on camera access at Settings > Privacy > Camera > TOYOTA Privilege")
                }
                
            });
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if (captureSession?.running == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            return
        }
        //        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            let barCodeObject = previewLayer?.transformedMetadataObjectForMetadataObject(metadataObject as! AVMetadataObject)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundCode(readableObject.stringValue);
        }
        
        //        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func foundCode(result: String) {
        //do something
//        print("QR result is \(result)")
        
        if result.rangeOfString("www.toyotaprivilege.com") != nil{
            let privilegeCode : String = getQueryStringParameter(result, param: "privilege_code")!
            captureSession.stopRunning()
            var urlString : String = String(Util().userDefaults.objectForKey("currentUrl")!)
            if urlString.rangeOfString("&sid") != nil{
                urlString = Util().cutUrlParameter(urlString, paramName: "sid")!
            }
            
            if urlString.rangeOfString("&privilege_code") != nil{
                urlString = Util().cutUrlParameter(urlString, paramName: "privilege_code")!
            }
            
            if urlString.rangeOfString("&lat") != nil{
                urlString = Util().cutUrlParameter(urlString, paramName: "lat")!
            }
            
            if urlString.rangeOfString("&lon") != nil{
                urlString = Util().cutUrlParameter(urlString, paramName: "lon")!
            }

            if checkLocationPermission(){
                let lat = locationManager.location?.coordinate.latitude
                let lon = locationManager.location?.coordinate.longitude
                urlString = "\(urlString)&privilege_code=\(privilegeCode)&lat=\(lat!)&lon=\(lon!)"
                Util().userDefaults.setObject(urlString, forKey: "currentUrl")
                
                //Alert for test
//                showAlertTest("Go to Get Redeem From Qr Url", message: urlString)
                Util().userDefaults.setBool(true, forKey: "afterQrScan")
                dismissViewControllerAnimated(true, completion: {})
            }else{
                urlString = "\(urlString)&privilege_code=\(privilegeCode)&lat=&lon="
                Util().userDefaults.setObject(urlString, forKey: "currentUrl")
                //Alert for test
//                showAlertTest("Go to Get Redeem From Qr Url", message: urlString)
                Util().userDefaults.setBool(true, forKey: "afterQrScan")
                dismissViewControllerAnimated(true, completion: {})

            }
            
        }else{
            captureSession.stopRunning()
            showAlert("Wrong QR Code", message: "Please try new QR code")
        }
    }
    
    func checkLocationPermission() -> Bool{
        if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.authorizationStatus() == .Denied{
            return false
        }else{
            return true
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        let url = NSURLComponents(string: url)!
        return
            ((((url.queryItems)! as [NSURLQueryItem])))
                .filter({ (item) in item.name == param }).first?
                .value!
    }
}
