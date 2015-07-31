//
//  NewLocationStruct.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 30.07.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation

struct NewLocation{
    let address : NSDictionary?
    let coordinates: NSDictionary?
    //    var details: NSMutableDictionary?
    var details: NSDictionary?
    let category: NSDictionary?
    
    init(address: NSDictionary?, coordinates: NSDictionary?, details: NSDictionary?, category: NSDictionary?){
        
        self.address = address
        self.coordinates = coordinates
        self.details = details
        self.category = category
    }
}