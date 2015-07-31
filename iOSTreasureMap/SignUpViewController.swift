//
//  SignUpViewController.swift
//  iOSTreasureMap
//
//  Created by Anna-Lena Hunold on 08/07/15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation
import UIKit


class SignUpViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    var loggedIn = false;
    
    @IBAction func SignUpButtonPressed(sender: AnyObject) {
        
        var name:String = nameTextfield.text as String
        var email:String = emailTextfield.text as String
        var password:String = passwordTextfield.text as String
        var provider:NSString = "local" as NSString
        
        if (name.isEmpty) || (email.isEmpty) || (password.isEmpty){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter Username, Email address and Password."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
            
        else if (email.rangeOfString("@") == nil){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter a valid Email address."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            return;
        } else {
            
            NSUserDefaults.standardUserDefaults().setObject(name, forKey: "name")
            NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
            NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
            NSUserDefaults.standardUserDefaults().synchronize()
                                
                var url:NSURL = NSURL(string: "http://treasuremap-stage.herokuapp.com/api/users")!
                
                var postData:NSData = ("provider=\(provider)&name=\(name)&email=\(email)&password=\(password)").dataUsingEncoding(NSASCIIStringEncoding)!
                
                var postLength:NSString = String( postData.length )
                
                var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
                
                if (urlData != nil) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        var string = ("Response: \(responseData)")
                        var error: NSError?
                        
                        let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                        
                            println("Sig up succesfull.")
                        
                            var user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            user.setInteger(1, forKey: "loggedIn")
                            let UserIsLoggedIn:Int = user.integerForKey("loggedIn") as Int
                            println(UserIsLoggedIn)
                            user.synchronize()
                            
                            self.loggedIn = true;
                         
                    } else {
                        var alert = UIAlertController(title: "Sign up failed.", message: "Unknown Error. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                        
                }
            
            if(self.loggedIn == true) {
                changeView()
            }
                
            
        }
            
    }
    
    func changeView() {
        let mapView = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! UIViewController
        self.navigationController!.pushViewController(mapView, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()

    
    }
}