//
//  ImageViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 10.06.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation
import AssetsLibrary

class ImageViewController: UIViewController, UIImagePickerControllerDelegate{
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionBox: UITextField!
    //@IBOutlet weak var uploadButton: UIButton!
    
    lazy var data = NSMutableData()
    let locationEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations")
    var rootViewController: DetailViewController?
    
    let CognitoRegionType = AWSRegionType.EUWest1  // e.g. AWSRegionType.USEast1
    let DefaultServiceRegionType = AWSRegionType.EUWest1 // e.g. AWSRegionType.USEast1
    let CognitoIdentityPoolId = "eu-west-1:5f5f3ce2-9d1e-4c70-ada7-0ebcfc08c16c"
    let S3BucketName = "treasure-map"
    
    var uploadRequests = Array<AWSS3TransferManagerUploadRequest?>()
    var uploadFileURLs = Array<NSURL?>()
    var downloadRequests = Array<AWSS3TransferManagerDownloadRequest?>()
    var downloadFileURLs = Array<NSURL?>()
    
    
    var location: Location!
    var photoFromRootView: UIImage!
    var mediaTypeFromRootView: NSString!
    var photoData: Dictionary<NSObject, AnyObject>?
    var photoUrl: String?
    var id: String?
    @IBOutlet weak var photoUploadProgress: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var error = NSErrorPointer()
        if !NSFileManager.defaultManager().createDirectoryAtPath(
            NSTemporaryDirectory().stringByAppendingPathComponent("upload"),
            withIntermediateDirectories: true,
            attributes: nil,
            error: error) {
                println("Creating 'upload' directory failed. Error: \(error)")
        }
        
        //photoUploadProgress.hidden = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.imageView.contentMode = .ScaleAspectFit
        imageView.image = photoFromRootView
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func uploadButtonPressed(sender: AnyObject) {
        //for (index, imageDictionary) in enumerate(photoData!) {
        //for (index, imageDictionary) in photoData!{
        //for(var index = 0; index < photoData!.count; index++){
        //for (index, imageDictionary) in enumerate(photoData!) {
        if let imageDict = photoData as? Dictionary<String, AnyObject> {
            //if let mediaType = imageDictionary[UIImagePickerControllerMediaType] as? String {
            if let mediaType =  photoData?[UIImagePickerControllerMediaType] as? String{
                //        if let mediaType = mediaTypeFromRootView as? String{
                let alAsset = ALAssetTypePhoto
                //if mediaType == ALAssetTypePhoto {
                if let image = imageDict[UIImagePickerControllerOriginalImage] as? UIImage {
                    if let photo = imageView.image as UIImage? {
                        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
                        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("upload/").stringByAppendingPathComponent(fileName)
                        println("filePath: \(filePath)")
                        let imageData = UIImagePNGRepresentation(image)
                        imageData.writeToFile(filePath, atomically: true)
                        
                        let uploadRequest = AWSS3TransferManagerUploadRequest()
                        uploadRequest.body = NSURL(fileURLWithPath: filePath)
                        uploadRequest.key = "images/" + fileName
                        uploadRequest.bucket = S3BucketName
                        
                        photoUrl = "images/" + fileName
                        
                        self.uploadRequests.append(uploadRequest)
                        self.uploadFileURLs.append(nil)
                        
                        self.upload(uploadRequest)
                    }
                }
                //}
            }
        }
        //}
        
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        println("uploading...")
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.imageView.reloadInputViews()
                            })
                            break;
                            
                        default:
                            println("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        println("upload() failed: [\(error)]")
                    }
                } else {
                    println("upload() failed: [\(error)]")
                }
            }
            if let exception = task.exception {
                println("upload() failed: [\(exception)]")
            }
            if (task.result == nil){
                let doof = "doof"
            }
            
            if (task.result != nil) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
                        uploadRequest.uploadProgress = { (bytesSent:Int64, totalBytesSent:Int64,  totalBytesExpectedToSend:Int64) -> Void in
                            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                            })
                        }
                        //self.updateProgressView(bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
                        self.uploadRequests[index] = nil
                        self.uploadFileURLs[index] = uploadRequest.body
                        let url = "https://treasure-map.s3.eu-central-1.amazonaws.com/" + "\(self.photoUrl!)"
                        let locationController = LocationController(locationEndpoint: self.locationEndpoint!, data: self.data)
                        self.rootViewController!.rootViewController!.locationController!.writeJSONData(self.rootViewController!.detailsFromRootView, content: url, writeTo: "details")
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        //self.imageView.reloadItemsAtIndexPaths([indexPath])
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                })
            }
            
            return nil
        }
        
    }
    
    func indexOfUploadRequest(array: Array<AWSS3TransferManagerUploadRequest?>, uploadRequest: AWSS3TransferManagerUploadRequest?) -> Int? {
        for (index, object) in enumerate(array) {
            if object == uploadRequest {
                return index
            }
        }
        return nil
    }
    
    
    func updateProgressView(bytesSent:Int64, totalBytesSent:Int64,  totalBytesExpectedToSend:Int64)
    {
        self.view.addSubview(photoUploadProgress)
        self.photoUploadProgress.hidden = false
        self.photoUploadProgress.sendSubviewToBack(self.view)
        //self.view.alpha = 0.3
        var uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        self.photoUploadProgress.progress = uploadProgress
        self.photoUploadProgress.setProgress(uploadProgress, animated: true)
        
        //        let progressPercent = Int(uploadProgress*100)
        //        progressLabel.text = “\(progressPercent)%”
        //        println(uploadProgress)
    }
}



