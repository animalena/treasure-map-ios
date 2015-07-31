//
//  AppDelegate.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 27.04.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , NSURLConnectionDataDelegate {
    
    var window: UIWindow?
    let cognitoAccountId = "treasure-map"
    let cognitoIdentityPoolId = "eu-west-1:5f5f3ce2-9d1e-4c70-ada7-0ebcfc08c16c"
    //let cognitoUnauthRoleArn = "xxxxxxxxxxxxxxxxx"
    let cognitoAuthRoleArn = "xxxxxxxxxxxxxxxxx"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //API Client-Key for Google Maps
        GMSServices.provideAPIKey("AIzaSyC49fkrQRd5yDgRszSHSga9KRfOmussA9g")
        
        let user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let loggedIn:Int = user.integerForKey("loggedIn")as Int
        
        println(loggedIn)
        
        if (loggedIn != 1) {
            println("user is not logged in")
            
            // show the login view straight away if user is not logged in
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            // navigation controller needs to be initial view controller in order to have the navigation bar
            let navigationController:UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            let rootViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
            navigationController.viewControllers = [rootViewController]
            self.window?.rootViewController = navigationController
            
        }
        
        //call AWS Services.
        //Code from https://docs.aws.amazon.com/mobile/sdkforios/developerguide/setup.html#
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.EUWest1, identityPoolId: cognitoIdentityPoolId)
        
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.EUCentral1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

