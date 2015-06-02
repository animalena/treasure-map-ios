import Foundation

class LocationController: NSObject{
    
    var locationEndpoint : NSURL
    var data: NSData
    var locations = [Location]()
    
    init(locationEndpoint: NSURL, data: NSData){
        self.locationEndpoint = locationEndpoint
        self.data = data
    }
    
    func getLocations() -> [Location]?{
        var json: NSArray = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSArray)
        var addressDict = [String: String]()
        var detailDict = [String: String]()
        var categoryDict = [String: String]()
        var coordinatesDict = [String: Float]()
        var id = String()
        
        if let parsed = json as? NSArray{
            for(var x = 0; x<parsed.count; x++){
                if let location = parsed[x] as? NSDictionary{
                    if let _id = location["_id"] as? String{
                        id = _id
                    }
                    if let address = location["address"] as? NSDictionary{
                        
                        if let street = address["street"] as? String{
                            addressDict["street"] = street
                        }
                        if let city = address["city"] as? String{
                            addressDict["city"] = city
                        }
                        if let zipcode = address["zipcode"] as? String{
                            addressDict["zipcode"] = zipcode
                        }
                    }
                    //println(addressDict)
                    if let coordinates = location["coordinates"] as? NSDictionary{
                        if let lat = coordinates["lat"] as? Float{
                            coordinatesDict["lat"] = lat
                        }
                        if let lng = coordinates["lng"] as? Float{
                            coordinatesDict["lng"] = lng
                        }
                    }
                    if let details = location["details"] as? NSDictionary{
                        if let category = details["category"] as? NSDictionary{
                            if let imgUrl = category["imgUrl"] as? String{
                                categoryDict["imgUrl"] = imgUrl
                            }
                            if let name = category["name"] as? String{
                                categoryDict["name"] = name
                            }
                        }
                        if let description = details["description"] as? String{
                            detailDict["description"] = description
                        }
                        if let duration = details["duration"] as? Int{
                            detailDict["duration"] = String(duration)
                        }
                        if let name = details["name"] as? String{
                            detailDict["name"] = name
                        }
                        if let pictures = details["pictures"] as? String{
                            detailDict["pictures"] = pictures
                        }
                    }
                    
                    
                }
                var newLocation = Location(address: addressDict, coordinates: coordinatesDict, details: detailDict, category: categoryDict, id: id)
                locations.append(newLocation)
            }
            
        }
        return locations
    }
    
    
    func getLocationDetails(locationId: String) -> Location{
        var loc = Location(address: nil, coordinates: nil, details: nil, category: nil, id: nil)
        for(var x=0; x<locations.count;x++){
            if(locationId == locations[x].id){
                loc = locations[x]
                return loc
            }
        }
        return loc
    }
}