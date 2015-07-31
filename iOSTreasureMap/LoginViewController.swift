//
//  LoginViewController.swift
//  iOSTreasureMap
//
//  Created by Anna-Lena Hunold on 14.06.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var loggedIn = false;
    
    @IBOutlet var emailTextfield : UITextField!
    @IBOutlet var pwTextfield : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hides the back button of the navigation bar
        var barBack = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = barBack
    }
    
//    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
//        // Store API AuthToken and AuthToken expiry date in KeyChain
//        tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
//            var myKey = dictKey as! String
//            var myObj = dictObj as! String
//            
//            if myKey == "api_authtoken" {
//                Keychain.setPassword(myObj, account: "Auth_Token", service: "KeyChainService")
//            }
//            
//            if myKey == "authtoken_expiry" {
//                Keychain.setPassword(myObj, account: "Auth_Token_Expiry", service: "KeyChainService")
//            }
//        })
//        
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        
        var email:String = emailTextfield.text as String
        var password:String = pwTextfield.text as String
        
        // check if both email and password have been entered
        if (email.isEmpty) || (password.isEmpty) {
            var alert = UIAlertController(title: "Forgot something?", message: "Please enter both email address and password.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if email.rangeOfString("@") == nil{
            var alert = UIAlertController(title: "Forgot something?", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            return;
        }
        
        emailTextfield.resignFirstResponder()
        pwTextfield.resignFirstResponder()
        
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(email, forKey: "email")
        defaults.setObject(password, forKey: "password")
        
        var session = NSURLSession.sharedSession()
        
        // NSURL is an object that contains the URL
        let url = NSURL(string: "http://treasuremap-stage.herokuapp.com/auth/local")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(["email": email, "password": password] as Dictionary<String, String>, options: nil, error: &error)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response header: \(response)")
            var responseBody = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println("Body: \(strData)")
            var err: NSError?
            
            let json = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&err) as! NSDictionary
            
            let token = (json as NSDictionary)["token"] as! String
            
            //println("Session token: \(token)")
            
            let res = response as! NSHTTPURLResponse!;
            
            var string = ("Response body: \(responseBody)")
            
            if res.statusCode == 401 {
                var alert = UIAlertController(title: "Sign in failed.", message: "You have either entered an incorrect email address password combination or you are not a registered user yet. Please try again or sign up.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else if (res.statusCode >= 200 && res.statusCode < 300) {
                var user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                user.setInteger(1, forKey: "loggedIn")
                let UserIsLoggedIn:Int = user.integerForKey("loggedIn") as Int
                println(UserIsLoggedIn)
                user.synchronize()
                
                self.loggedIn = true;
                
            } else {
                var alert = UIAlertController(title: "Sign in failed.", message: "Unknown Error. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        })
        
        if(self.loggedIn == true) {
            self.changeView()
        }
        
        task.resume()
    }
    
    func changeView() {
        let mapView = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! UIViewController
        self.navigationController!.pushViewController(mapView, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
