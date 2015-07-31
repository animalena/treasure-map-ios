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
        var detailDict = [String: AnyObject]()
        var categoryDict = [String: String]()
        var coordinatesDict = [String: Float]()
        var id = String()
        var pictureArray = [String]()
        
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
                        if let lat = coordinates["latitude"] as? Float{
                            coordinatesDict["latitude"] = lat
                        }
                        if let lng = coordinates["longitude"] as? Float{
                            coordinatesDict["longitude"] = lng
                        }
                    }
                    if let details = location["details"] as? NSDictionary{

                        detailDict["category"] = categoryDict
                        if let description = details["description"] as? String{
                            detailDict["description"] = description
                        }
                        if let duration = details["duration"] as? Int{
                            detailDict["duration"] = String(duration)
                        }
                        if let name = details["name"] as? String{
                            detailDict["name"] = name
                        }
                        if let category = details["category"] as? NSDictionary{
                            if let imgUrl = category["imgUrl"] as? String{
                                categoryDict["imgUrl"] = imgUrl
                            }
                            if let name = category["name"] as? String{
                                categoryDict["name"] = name
                            }
                        }
                        if let pictures = details["pictures"] as? NSMutableArray{
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
    
    func convertJSONValid(location: Location) -> NSDictionary{
        var validLocation = [String: AnyObject]()
        
        validLocation["address"] = location.address
        validLocation["coordinates"] = location.coordinates
        validLocation["details"] = location.details
        validLocation["_id"] = location.id
        
        return validLocation
    }
    
    func convertJSONValidNewLocation(location: NewLocation) -> NSDictionary{
        var validLocation = [String: AnyObject]()
        
        validLocation["address"] = location.address
        validLocation["coordinates"] = location.coordinates
        validLocation["details"] = location.details
        
        return validLocation
    
    }
    
    func deepCopyLocation(location: Location, newValue: AnyObject?) -> Location{
        var addressDict = [String: String]()
        var detailDict = [String: AnyObject]()
        var coordinatesDict = [String: Float]()
        var categoryDict = [String: String]()
        
        var street = location.address?.valueForKey("street")!.copy() as? String
        var city = location.address?.valueForKey("city")!.copy() as? String
        var zipcode = location.address?.valueForKey("zipcode")!.copy() as? String
        
        var latitude = location.coordinates?.valueForKey("latitude")!.copy() as? Float
        var longitude = location.coordinates?.valueForKey("longitude")!.copy() as? Float
        
        if let category = location.coordinates?.valueForKey("category")?.copy() as? NSDictionary{
            detailDict["category"] = category
        }
        var description = location.details?.valueForKey("description")!.copy() as? String
        var duration = location.details?.valueForKey("duration")!.copy() as? String
        var name = location.details?.valueForKey("name")!.copy() as? String
        var pictures : [String]
        pictures = (newValue as? [String])! //as? NSMutableArray
        
        var imgUrl = location.category?.valueForKey("imgUrl")?.copy() as? String
        var categoryName = location.category?.valueForKey("name")?.copy() as? String
        
        addressDict["street"] = street
        addressDict["city"] = city
        addressDict["zipcode"] = zipcode
        
        coordinatesDict["latitude"] = latitude
        coordinatesDict["longitude"] = longitude
        
        categoryDict["imgUrl"] = imgUrl
        categoryDict["name"] = categoryName
        
        detailDict["description"] = description
        detailDict["duration"] = duration
        detailDict["name"] = name        
        detailDict["category"] = categoryDict
        detailDict["pictures"] = pictures
        
        var locationCopy = Location(address: addressDict, coordinates: coordinatesDict, details: detailDict, category: categoryDict, id: location.id)
        
        return locationCopy
    }
    
    func saveLocation(location: NewLocation){
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        var request = NSMutableURLRequest(URL: locationEndpoint)
        var responseError: NSError?
        var response: NSURLResponse?

        
        var validLocation = convertJSONValidNewLocation(location)
        var error: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(validLocation, options: nil, error: &error)!
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body
        NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &responseError)
        println("Hallo")
    }
    
    func writeJSONData(location: Location, content: String, writeTo: String){
        
        var url = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations/" + location.id!)
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        var request = NSMutableURLRequest(URL: url!)
        var responseError: NSError?
        var response: NSURLResponse?
        
        //deep copy of location, so we dont change the original yet
        var detailsCopy: AnyObject? = location.details!.copy()
        var updatedDetails = detailsCopy!.mutableArrayValueForKey("pictures").arrayByAddingObject(content)
        var newLoc = deepCopyLocation(location, newValue: updatedDetails)
        
   
        var validLocation = convertJSONValid(newLoc)
        var error: NSError?
        let body = NSJSONSerialization.dataWithJSONObject(validLocation, options: nil, error: &error)!
        request.HTTPMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         request.HTTPBody = body
        NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &responseError)
        println("done")
    }
    
}
