//
//  Location.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 07.05.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation

//cannot be a struct because we need it to conform to AnyObject to enable writing
class Location{
    
    let address : NSDictionary?
    let coordinates: NSDictionary?
    //    var details: NSMutableDictionary?
    var details: NSDictionary?
    let category: NSDictionary?
    let id : String?
    
    init(address: NSDictionary?, coordinates: NSDictionary?, details: NSDictionary?, category: NSDictionary?, id : String?){
        
        self.address = address
        self.coordinates = coordinates
        self.details = details
        self.category = category
        self.id = id
        
    }
}

    