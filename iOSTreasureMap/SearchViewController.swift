//
//  SearchViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 20.07.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, UITableViewDelegate, GMSMapViewDelegate{

    @IBOutlet weak var autocompleteView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    lazy var data = NSMutableData()
    var locations: [Location]?
    var autocompleteLocations = [Location]()    
    var searchMap: GMSMapView!
    var marker = GMSMarker()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        var locationEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations/")
        var data = NSData(contentsOfURL: locationEndpoint!)
        locations = LocationController(locationEndpoint: locationEndpoint!, data: data!).getLocations()
        autocompleteView?.hidden = true
        searchbar.delegate = self
        autocompleteView?.delegate = self
        self.view.addSubview(searchbar!)
        
        // Google Maps
        var camera = GMSCameraPosition.cameraWithLatitude(52.51631,
            longitude: 13.40784, zoom: 10)
        searchMap = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        //searchMap?.settings.myLocationButton = true
        //searchMap?.settings.compassButton = true
        //searchMap?.myLocationEnabled = true
        searchMap.animateToZoom(12)
        searchMap.setMinZoom(10, maxZoom: 15)
        
        //self.view.addSubview(searchMap)
        searchMap.delegate = self
        
        self.view.addSubview(searchMap!)
        self.view.bringSubviewToFront(searchbar)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        autocompleteView?.scrollEnabled = true
        autocompleteView?.hidden = true
        autocompleteView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(autocompleteView!)
        autocompleteView?.hidden = false
    
        var substring : NSString = searchbar.text
        substring = substring.stringByReplacingCharactersInRange(range, withString: text)
        autocomplete(substring)
        return true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        autocompleteLocations.removeAll(keepCapacity: false)
        autocompleteView.hidden = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("count cells")
        return autocompleteLocations.count
    }

    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell
        cell!.textLabel!.text = autocompleteLocations[indexPath.row].details!.valueForKey("name") as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        marker.position = camera.target
//        marker.snippet = "This is my current location"
//        marker.appearAnimation = kGMSMarkerAnimationPop
//        marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())

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
    
    func autocomplete(substring: NSString){

        autocompleteLocations.removeAll(keepCapacity: false)

        for(var x = 0; x<locations!.count; x++){
            var cell = autocompleteView!.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
            cell = nil
            var locationName = locations![x].details!.valueForKey("name") as! NSString
            var substringRange : NSRange = locationName.rangeOfString(substring as String)
            if(substringRange.location == 0){
                autocompleteLocations.append(locations![x])
            }
        }
        autocompleteView?.reloadData()
    
    }
    
}