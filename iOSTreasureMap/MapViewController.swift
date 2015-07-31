//
//  ViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 27.04.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate{
    
    var viewMap: GMSMapView!
    var tappedPin: GMSMarker?
    var selectedLocation: Location?

    
    var radius : Double = 3000
    var marker = GMSMarker()
    
    lazy var data = NSMutableData()
    var locationEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations/")
    
    var locationManager = CLLocationManager()
    var locationController : LocationController?
    var locations: [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        
        // Google Maps
        var camera = GMSCameraPosition.cameraWithLatitude(52.51631,
            longitude: 13.40784, zoom: 10)
//        viewMap = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        let mapRect = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - 50))
        viewMap = GMSMapView.mapWithFrame(mapRect, camera: camera)
        viewMap?.settings.myLocationButton = true
        viewMap?.settings.compassButton = true
        viewMap?.myLocationEnabled = true
        viewMap.animateToZoom(12)
        viewMap.setMinZoom(10, maxZoom: 15)
        
        //self.view.addSubview(viewMap)
        viewMap.delegate = self
        
        self.view = viewMap
        drawCircle()
        // current location marker
        marker.position = camera.target
        marker.snippet = "This is my current location"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                println("Error: " + error.localizedDescription)
            }
            
            if placemarks.count > 0
            {
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
                let location = self.locationManager.location
                var latitude: Double = location.coordinate.latitude
                var longitude: Double = location.coordinate.longitude
                //                println("current latitude :: \(latitude)")
                //                println("current longitude :: \(longitude)")
                
                let currLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        })
    }
    
    
    func displayLocationInfo(placemark: CLPlacemark)
    {
        self.locationManager.stopUpdatingLocation()
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            startConnection()
        } else {
            var notification = UILocalNotification()
            notification.alertBody = "There is a problem with the internet connection!"
            notification.alertAction = "Use in Offline mode"
            println("Internet connection FAILED")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawCircle() {
        var circleCenter = CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude)
        var circle = GMSCircle(position: circleCenter, radius: radius)
        circle.strokeColor = UIColor.blueColor()
        circle.fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        //circle.map = viewMap
    }
    
    func startConnection(){
        locationController = LocationController(locationEndpoint: locationEndpoint!, data: NSData(contentsOfURL: locationEndpoint!)!)
        
        
        let request = NSURLRequest(URL: locationEndpoint!)
        let connection = NSURLConnection(request: request, delegate: self)
        let data = NSData(contentsOfURL: locationEndpoint!)
        connection?.start()
        
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        var data = NSData(contentsOfURL: locationEndpoint!)
        locations = locationController!.getLocations()!
        
        
        var circleCenter = CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude)
        var circleCenterLat = marker.position.latitude
        var circleCenterLng = marker.position.longitude
        
        
        for(var x=0; x<locations.count; x++){
            
            var locationLat = locations[x].coordinates?.valueForKey("latitude") as? CLLocationDegrees
            var locationLng = locations[x].coordinates?.valueForKey("longitude") as? CLLocationDegrees
            var locationPosition = CLLocationCoordinate2DMake(locationLat!, locationLng!)
            var locationName = locations[x].details?.valueForKey("name") as! String
            var locationDuration = locations[x].details?.valueForKey("duration") as! String
            var locationCategory = locations[x].category?.valueForKey("name") as! String
            var locationMarker = GMSMarker(position: locationPosition)
            var pinString: String = locations[x].category?.valueForKey("imgUrl") as! String
            var pinUrl = NSURL(string: ("http://treasuremap-stage.herokuapp.com/" + pinString))
            var pinData = NSData(contentsOfURL: pinUrl!)
            
            let latitudeCircle: CLLocationDegrees = circleCenter.latitude
            let longitudeCircle: CLLocationDegrees = circleCenter.longitude
            
            let locationCircle: CLLocation = CLLocation(latitude: latitudeCircle,
                longitude: longitudeCircle)
            
            let latitudePos: CLLocationDegrees = locationPosition.latitude
            let longitudePos: CLLocationDegrees = locationPosition.longitude
            
            let locationPos: CLLocation = CLLocation(latitude: latitudePos,
                longitude: longitudePos)
            
            let dist = locationCircle.distanceFromLocation(locationPos)
            
            // only show markers if they are within the radius
            if (dist < radius){
                //println("Radius: \(radius)")
                locationMarker.title = "Location: \(locationName)"
                locationMarker.snippet = "Duration in Hours: \(locationDuration)" + "\n" +
                "Category: \(locationCategory)"
                locationMarker.icon = UIImage(data: pinData!, scale: 2)
                locationMarker.accessibilityValue = locations[x].id
                locationMarker.map = viewMap
            }
        }
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        //by tap auf myLocation Button: zoom, Location mittig
        //muss false sein, ansonsten funktioniert nur Detail View ODER current location
        return false
    }
    
    
    //bei tap auf Infofenster wird der Segue "tappedPin" ausgelöst: neues Fenster öffnet sich
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        //viewMap.delegate = self
        tappedPin = marker
        //erstellt eine Instanz des entsprechenden Storyboards
        let detailStoryboard = UIStoryboard(name: "DetailView", bundle: nil)
        //innerhalb dieses Storyboards wird der View Controller instanziiert (dem View Controller im Storyboard eine ID geben!)
        
        let detailView = detailStoryboard.instantiateViewControllerWithIdentifier("DetailViewID") as! DetailViewController
        //Wie soll der nächste View erscheinen?
        detailView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        //so können Informationen an den View weitergegeben werden
        //(didTapPin ist eine globale Variable im Detail View Controller)
        detailView.didTapPin = tappedPin!
        detailView.detailsFromRootView = locationController?.getLocationDetails(tappedPin!.accessibilityValue!)
        tappedPin = nil
        detailView.rootViewController = self
        //der eigentliche Aufruf des View Controllers
        self.presentViewController(detailView, animated: true, completion: nil)
    }
    
    @IBAction func logOut(sender: AnyObject) {

        println("logging out")
        
        var user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        user.setInteger(0, forKey: "loggedIn")
        user.synchronize()
        
        self.performSegueWithIdentifier("goToLogin", sender: self)
    }
    
    
    @IBAction func toggleSideMenu(sender: AnyObject){
        //MenuViewController().locations = self.locations
        
        toggleSideMenuView()
        
    }
}