//
//  Reachability.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 03.06.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

//Reachability class from
//http://stackoverflow.com/questions/25398664/check-for-internet-connection-availability-in-swift

import Foundation

public class Reachability {
    
    class func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/locations")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}