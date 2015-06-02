//
//  DetailViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 26.05.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation

class DetailViewController: UIViewController{

    var rootViewController = MapViewController()
    var didTapPin: GMSMarker!
    var detailsFromRootView: Location!
    @IBOutlet weak var locationDetails: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = didTapPin.title
        var street = detailsFromRootView.address?.valueForKey("street") as! String
        var zip = detailsFromRootView.address?.valueForKey("zipcode") as! String
        var city = detailsFromRootView.address?.valueForKey("city") as! String
        locationDetails.text = "Address: \(street)" + "\n" + "\(zip)" + "\n" + "\(city)"
        // self.editButtonItem().tintColor = UIColor(red: 158, green: 0, blue: 93, alpha: 1)
       
    }
}