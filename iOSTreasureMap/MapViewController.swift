//
//  ViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 27.04.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate{

    //@IBOutlet weak var viewMap: GMSMapView!
    var viewMap: GMSMapView!
    var tappedPin: GMSMarker?
    var selectedLocation: Location?
    @IBOutlet weak var toolbar: UINavigationItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //var locationMarker: GMSMarker!

    var marker = GMSMarker()
    var radius : Double = 3000

    lazy var data = NSMutableData()
    let locationEndpoint = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations")!

    let locationManager = CLLocationManager()
    let locationController = LocationController(locationEndpoint: NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations")!, data: NSData(contentsOfURL: NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations")!)!)

    override func viewDidLoad() {
        super.viewDidLoad()

        var buttonImg = UIImage(named: "burgerMenu_small")
        menuButton.setBackButtonBackgroundImage(buttonImg, forState: .Normal, barMetrics: .Default)

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        // Google Maps
        var camera = GMSCameraPosition.cameraWithLatitude(52.51631,
            longitude: 13.40784, zoom: 10)
        viewMap = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        viewMap?.settings.myLocationButton = true
        viewMap?.settings.compassButton = true
        viewMap?.myLocationEnabled = true
        viewMap.animateToZoom(12)
        viewMap.setMinZoom(10, maxZoom: 15)

        // current location marker
        marker.position = camera.target
        marker.snippet = "This is my current location"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        marker.map = viewMap

        //viewMap.delegate = self
        self.view = viewMap

        drawCircle()

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
                println("current latitude :: \(latitude)")
                println("current longitude :: \(longitude)")

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
        startConnection()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func drawCircle() {
        var circleCenter = CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude)
        var circle = GMSCircle(position: circleCenter, radius: radius)
        circle.strokeColor = UIColor.blueColor()
        circle.fillColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.2)
        circle.map = viewMap;
    }

    func startConnection(){
        let request = NSURLRequest(URL: locationEndpoint)
        let connection = NSURLConnection(request: request, delegate: self)
        let data = NSData(contentsOfURL: locationEndpoint)

        connection?.start()
    }

    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError
        let data = NSData(contentsOfURL: locationEndpoint)!
        locationController.getLocations()

        var circleCenter = CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude)
        var circleCenterLat = marker.position.latitude
        var circleCenterLng = marker.position.longitude

        for(var x=0; x<locationController.locations.count; x++){
            var locationLat = locationController.locations[x].coordinates!.valueForKey("lat") as! CLLocationDegrees
            var locationLng = locationController.locations[x].coordinates!.valueForKey("lng") as! CLLocationDegrees
            var locationPosition = CLLocationCoordinate2DMake(locationLat, locationLng)
            var locationName = locationController.locations[x].details?.valueForKey("name") as! String
            var locationDuration = locationController.locations[x].details?.valueForKey("duration") as! String
            var locationCategory = locationController.locations[x].category?.valueForKey("name") as! String
            var locationMarker = GMSMarker(position: locationPosition)
            var pinString: String = locationController.locations[x].category?.valueForKey("imgUrl") as! String
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
            locationMarker.title = "Location: \(locationName)"
            locationMarker.snippet = "Duration in Hours: \(locationDuration)" + "\n" +
            "Category: \(locationCategory)"
            locationMarker.icon = UIImage(data: pinData!, scale: 2)
            locationMarker.accessibilityValue = locationController.locations[x].id
            locationMarker.map = viewMap
            }
        }
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        //by tap auf myLocation Button: zoom, Location mittig
        return true
    }
    
    //bei tap auf Infofenster wird der Segue "tappedPin" ausgelöst: neues Fenster öffnet sich
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        tappedPin = marker
        self.performSegueWithIdentifier("tappedPin", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        if(segue.identifier == "tappedPin"){
        //               let detailView = segue.destinationViewController as! DetailViewController
        //                detailView.didTapPin = tappedPin!
        //                detailView.detailsFromRootView = locationController.getLocationDetails(tappedPin!.accessibilityValue!)
        //        }
        if let detailView = segue.destinationViewController as? DetailViewController{
            detailView.rootViewController = self
            detailView.didTapPin = tappedPin!
            detailView.detailsFromRootView = locationController.getLocationDetails(tappedPin!.accessibilityValue!)
            println("its happening")
        }
    }

    @IBAction func toggleSideMenu(sender: AnyObject){
        toggleSideMenuView()

    }
}