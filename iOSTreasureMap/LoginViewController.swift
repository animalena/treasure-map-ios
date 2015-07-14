//
//  LoginViewController.swift
//  iOSTreasureMap
//
//  Created by Anna-Lena Hunold on 14.06.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, NSURLConnectionDataDelegate {
    
    var loggedIn = false;
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var pwTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login(sender: AnyObject) {
        
        if (emailTextfield.text == "" || pwTextfield.text == "") {
            var alert = UIAlertView()
            alert.title = "You must enter both email address and password!"
            alert.addButtonWithTitle("Ok, let's try again")
            alert.show()
            return;
        }
        
        emailTextfield.resignFirstResponder()
        pwTextfield.resignFirstResponder()
        
        var parameters = ["email": emailTextfield.text, "password": pwTextfield.text] as Dictionary<String, String>
        
        let url = NSURL(string: "http://treasuremap-stage.herokuapp.com/auth/local")
        
        var session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var string = ("Body: \(strData)")
            if string.rangeOfString("token") != nil{
                self.loggedIn = true;
            } else {
                println("not regisered!")
                let alert = UIAlertView()
                alert.title = "This email is not registered."
                alert.addButtonWithTitle("Try another email.")
                alert.show()
            }
            
            
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                if let parseJSON = json {
                    var success = parseJSON["success"] as? Int
                    //self.loggedIn = true;
                }
                else {
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
            
            
        })
        
        if(self.loggedIn == true) {
            self.performSegueWithIdentifier("goToMap", sender: sender)
           // LocationController().writingEnabled == true
        }
        
        task.resume()
    }
    
    /*
    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
    // Store API AuthToken and AuthToken expiry date in KeyChain
    tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
    var myKey = dictKey as! String
    var myObj = dictObj as! String
    
    if myKey == "api_authtoken" {
    Keychain.setPassword(myObj, account: "Auth_Token", service: "KeyChainService")
    }
    
    if myKey == "authtoken_expiry" {
    Keychain.setPassword(myObj, account: "Auth_Token_Expiry", service: "KeyChainService")
    }
    })
    
    self.dismissViewControllerAnimated(true, completion: nil)
    }
    */
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //performSegueWithIdentifier("goToMap", sender: self)
        
        if self.emailTextfield.isFirstResponder(){
            self.emailTextfield.resignFirstResponder()
        }
        
        if self.pwTextfield.isFirstResponder() {
            self.pwTextfield.becomeFirstResponder()
        }
        
        
        
        if(loggedIn == true) {
            println("logged in")
        } else {
            println("not logged in")
        }
        
    }
    
    
    
    
    //logout request.deleteValue
    
    /*
    var json: NSArray = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSArray)
    var email = [String: String]()
    var password = [String: String]()
    
    var local : NSJSONSerialization.JSONObjectWithData =
    
    var url : String = "http://treasuremap-stage.herokuapp.com/auth/" + local
    var request : NSMutableURLRequest = NSMutableURLRequest()
    request.URL = NSURL(string: url)
    request.HTTPMethod = "POST"
    
    //asynchronous request
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
    var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
    let jsonResult: NSArray! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSArray
    
    if (jsonResult != nil) {
    println(jsonResult)
    } else {
    println("no results")
    
    }
    
    })
    
    }
    */
    
    
}