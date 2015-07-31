//
//  SearchViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 20.07.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, UITableViewDelegate, GMSMapViewDelegate{

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var autocompleteView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    lazy var data = NSMutableData()
    var locations: [Location]?
    var selectedLocation : Location?
    var autocompleteLocations = [Location]()    

    var searchMap: GMSMapView!
    var marker = GMSMarker()
    var tappedPin: GMSMarker?
    var locationController : LocationController?

    
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
            longitude: 13.40784, zoom: 1)
        let mapRect = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - self.searchbar.frame.height))
        searchMap = GMSMapView.mapWithFrame(mapRect, camera: camera)
        searchMap.animateToZoom(12)
        searchMap.setMinZoom(10, maxZoom: 15)

        searchMap.delegate = self
        self.view.addSubview(searchMap)
        autocompleteView?.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = menuButton

    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        autocompleteView?.scrollEnabled = true
        autocompleteView?.hidden = false
        autocompleteView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(autocompleteView!)
       // autocompleteView?.hidden = false
    
        var substring : NSString = searchbar.text
        substring = substring.stringByReplacingCharactersInRange(range, withString: text)
        autocomplete(substring)
        
        return true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        autocompleteLocations.removeAll(keepCapacity: false)
        autocompleteView.hidden = true
        searchbar.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("count cells")
        return autocompleteLocations.count
    }

    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = autocompleteLocations[indexPath.row].details!.valueForKey("name") as? String
            var street = autocompleteLocations[indexPath.row].address!.valueForKey("street") as! String
            var zipcode = autocompleteLocations[indexPath.row].address!.valueForKey("zipcode") as! String
            var city = autocompleteLocations[indexPath.row].address!.valueForKey("city") as! String
            cell.detailTextLabel?.text = "\(street),  \(zipcode),  \(city)"
            selectedLocation = autocompleteLocations[indexPath.row]

        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        var locationName = autocompleteLocations[indexPath.row].details!.valueForKey("name") as! String
        var duration = autocompleteLocations[indexPath.row].details!.valueForKey("duration") as! String
        var category = autocompleteLocations[indexPath.row].category!.valueForKey("name") as! String
        var pinString: String = autocompleteLocations[indexPath.row].category!.valueForKey("imgUrl") as! String
        var pinUrl = NSURL(string: ("http://treasuremap-stage.herokuapp.com/" + pinString))
        var pinData = NSData(contentsOfURL: pinUrl!)
        var lat = autocompleteLocations[indexPath.row].coordinates!.valueForKey("latitude") as! CLLocationDegrees
        var lng = autocompleteLocations[indexPath.row].coordinates!.valueForKey("longitude") as! CLLocationDegrees
        var position = CLLocationCoordinate2DMake(lat, lng)
        
        marker.position = position
        marker.title = "Location: \(locationName)"
        marker.snippet = "Duration in Hours: \(duration)" + "\n" +
        "Category: \(category)"
        marker.icon = UIImage(data: pinData!, scale: 2)
        marker.accessibilityValue = autocompleteLocations[indexPath.row].id
        marker.map = searchMap
        searchbar.endEditing(true)
        autocompleteView.hidden = true
        return indexPath
    }

    
    //bei tap auf Infofenster wird der Segue "tappedPin" ausgelöst: neues Fenster öffnet sich
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        var mapViewController = MapViewController()
        mapViewController.tappedPin = self.marker
        var locationEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations/")
        let data = NSData(contentsOfURL: locationEndpoint!)
        var locationController = LocationController(locationEndpoint: locationEndpoint!, data: NSData(contentsOfURL: locationEndpoint!)!)
       // mapViewController.viewMap = searchMap

        //erstellt eine Instanz des entsprechenden Storyboards
        let detailStoryboard = UIStoryboard(name: "DetailView", bundle: nil)
        //innerhalb dieses Storyboards wird der View Controller instanziiert (dem View Controller im Storyboard eine ID geben!)
        let detailView = detailStoryboard.instantiateViewControllerWithIdentifier("DetailViewID") as! DetailViewController
        //Wie soll der nächste View erscheinen?
        detailView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        //so können Informationen an den View weitergegeben werden
        //(didTapPin ist eine globale Variable im Detail View Controller)
        detailView.didTapPin = self.marker
        detailView.detailsFromRootView = selectedLocation
        detailView.rootViewController = mapViewController
        //der eigentliche Aufruf des View Controllers
        self.presentViewController(detailView, animated: true, completion: nil)

    }
    

    @IBAction func toggleSideMenu(sender: AnyObject) {
        toggleSideMenuView()
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
            var locationName = locations![x].details!.valueForKey("name") as! NSString
            var substringRange : NSRange = locationName.rangeOfString(substring as String)
            if(substringRange.location == 0){
                autocompleteLocations.append(locations![x])
            }
        }
        autocompleteView?.reloadData()
    
    }
    
}