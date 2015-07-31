//
//  NewLocationController.swift
//  iOSTreasureMap
//
//  Created by Denise Michaelis on 16.06.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//
import UIKit

class NewLocationController: UIViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var locationDescription: UITextField!
    
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var uploadedPhoto: UIImageView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var pickCategory: UIButton!
    @IBOutlet weak var categoryView: UITableView!
    
    var takePhoto:  UIImagePickerController?
    var pickImage: UIImagePickerController?
    var locationAdded : Location?
    
    @IBOutlet weak var menu: UIBarButtonItem!
    var photoData: Dictionary<NSObject, AnyObject>?
    
    let categoryEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/categories")!
    var pickerData = [String]()
    var foundStringOther = false
    
    var addressDict = [String: String]()
    var detailDict = [String: AnyObject]()
    var coordinatesDict = [String: Float]()
    //var categoryDict = [String: String]()
    var categoryDict : [String : String] = ["imgUrl" : "", "name" : ""]
    override func viewDidLoad() {
        super.viewDidLoad()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        categoryView.delegate = self
        categoryView.dataSource = self
        categoryView.hidden = true
        navigationItem.leftBarButtonItem = menu
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 7
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
    
    if (cell == nil) {
    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
    }
    
    switch (indexPath.row) {
    
    case 0:
    cell!.textLabel?.text = "Accommodation"
    //cell!.textLabel?.font = UIFont(name: "System Light", size: 15)
    var image: UIImage = UIImage(named: "AccommodationPin01")!
    cell!.imageView?.image = image
    case 1:
    cell!.textLabel?.text = "Food and Drinks"
    var image: UIImage = UIImage(named: "FoodDrinkPin00")!
    cell!.imageView?.image = image
    case 2:
    cell!.textLabel?.text = "Geocaching"
    var image: UIImage = UIImage(named: "GeocachingPin00")!
    cell!.imageView?.image = image
    case 3:
    cell!.textLabel?.text = "Leisure"
    var image: UIImage = UIImage(named: "LeisurePin00")!
    cell!.imageView?.image = image
    case 4:
    cell!.textLabel?.text = "Shopping"
    var image: UIImage = UIImage(named: "ShoppingPin00")!
    cell!.imageView?.image = image
    case 5:
    cell!.textLabel?.text = "Sights and Culture"
    var image: UIImage = UIImage(named: "SightsAndCulturePin00")!
    cell!.imageView?.image = image
    case 6:
    cell!.textLabel?.text = "Other"
    var image: UIImage = UIImage(named: "LeisurePin01")!
    cell!.imageView?.image = image
    default:
    cell!.textLabel?.text = " "
    }
    
    return cell!

    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch (indexPath.row){
        case 0:
            categoryDict["name"] = "Accommodation"
            categoryDict["imgUrl"] = "assets/images/AccommodationPin00.png"
        case 1:
            categoryDict["name"] = "Food & Drink"
            categoryDict["imgUrl"] = "assets/images/FoodDrinkPin00.png"
        case 2:
            categoryDict["name"] = "Geocaches"
            categoryDict["imgUrl"] = "assets/images/GeocachingPin00.png"
        case 3:
            categoryDict["name"] = "Leisure"
            categoryDict["imgUrl"] = "assets/images/LeisurePin00.png"
        case 4:
            categoryDict["name"] = "Shopping"
            categoryDict["imgUrl"] = "assets/images/ShoppingPin00.png"
        case 5:
            categoryDict["name"] = "Sights & Culture"
            categoryDict["imgUrl"] = "assets/images/SightsAndCulturePin00.png"            
        case 6:
            categoryDict["name"] = "Other"
            categoryDict["imgUrl"] = "assets/images/LeisurePin01.png"
        default:
            break
        }

        var pinString = categoryDict["imgUrl"]
        var pinUrl = NSURL(string: ("http://treasuremap-stage.herokuapp.com/" + pinString!))
        var pinData = NSData(contentsOfURL: pinUrl!)
        categoryIcon.image = UIImage(data: pinData!, scale: 2)
        categoryView.hidden = true
        return indexPath
    }

    @IBAction func pickCategoryAction(sender: AnyObject) {
        self.view.endEditing(true)
        categoryView.hidden = false
    }
    
    @IBAction func uploadPhoto(sender: AnyObject){
        self.view.endEditing(true)

        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default){
            UIAlertAction in
            self.takePhoto = UIImagePickerController()
            self.takePhoto?.delegate = self
            self.takePhoto?.sourceType = .Camera
            
            self.presentViewController(self.takePhoto!, animated: true, completion: nil)
        }
        var libraryAction = UIAlertAction(title: "Choose Photo from Library", style: UIAlertActionStyle.Default){
            UIAlertAction in
            self.pickImage = UIImagePickerController()
            self.pickImage?.delegate = self
            self.pickImage?.sourceType = .PhotoLibrary
            
            self.presentViewController(self.pickImage!, animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.view.backgroundColor = UIColor(red: 53, green: 53, blue: 53, alpha: 1)
        presentViewController(alert, animated: true, completion: nil)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let picker = pickImage{
            pickImage!.dismissViewControllerAnimated(true, completion: nil)
            uploadedPhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            photoData = info
        
        }
        
        if let picker = takePhoto{
            takePhoto!.dismissViewControllerAnimated(true, completion: nil)
            uploadedPhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            photoData = info
        }
    }

    
    @IBAction func nameEntered(sender: UITextField!) {
        detailDict["name"] = NSString(string: name.text)
    }
    
    @IBAction func streetEntered(sender: UITextField!) {
        addressDict["street"] = NSString(string: street.text) as String
    }
    
    @IBAction func zipcodeEntered(sender: AnyObject) {
        addressDict["zipcode"] = NSString(string: zipcode.text) as String
    }
    
    @IBAction func cityEntered(sender: AnyObject) {
        addressDict["city"] = NSString(string: city.text) as String
    }
    
    @IBAction func durationEntered(sender: AnyObject) {
        detailDict["duration"] = NSString(string: duration.text).integerValue
    }
    
    @IBAction func descriptionEntered(sender: AnyObject) {
        detailDict["description"] = NSString(string: locationDescription.text) as String
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
        
    }
    
    //code: http://stackoverflow.com/questions/28557798/using-gmsaddress-and-gmsgeocoder-to-return-coordinates-from-address-in-swift
    func geoLocate(address:String!){
        let gc:CLGeocoder = CLGeocoder()
        
        gc.geocodeAddressString(address, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            let pm = placemarks as! [CLPlacemark]
            if (placemarks.count > 0){
                let p = pm[0]
                
                var latitude = p.location.coordinate.latitude
                var longitude = p.location.coordinate.longitude

                self.coordinatesDict["latitude"] = Float(latitude)
                self.coordinatesDict["longitude"] = Float(longitude)
            }
        })
    }
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    @IBAction func SavePressed(sender: AnyObject) {
        let address = addressDict["street"]! + ", " + addressDict["zipcode"]! + ", "
        + addressDict["city"]! as String
        println("Address: \(address)")
        geoLocate(address)
        
        var saveLocation = NewLocation(address: addressDict, coordinates: coordinatesDict, details: detailDict, category: categoryDict)
        let locationEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations")
        let data = NSData(contentsOfURL: locationEndpoint!)
        LocationController(locationEndpoint: locationEndpoint!, data: data!).saveLocation(saveLocation)
        
    }
    override func viewWillAppear(animated: Bool) {
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}