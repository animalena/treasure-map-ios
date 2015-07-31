
//
//  MenuViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 11.05.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

import Foundation

class MenuViewController: UITableViewController{

    var selectedMenuItem : Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
//        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()      //darkGreyColor
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        switch (indexPath.row) {
        case 0:
            cell!.textLabel?.text = "Locations nearby"
        case 1:
           // cell!.textLabel?.text = "Add a Location"
         cell!.textLabel?.text = "Find a Location"
        //case 2:
           
        case 10:
            cell!.textLabel?.text = "Log Out"
        default:
             cell!.textLabel?.text = " "
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("did select row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
            return
        }
        selectedMenuItem = indexPath.row
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController = UIViewController()
        switch (indexPath.row) {
        case 0:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MapViewController")as! MapViewController
            sideMenuController()?.setContentViewController(destViewController)
            break
        case 1:
            let searchStoryboard: UIStoryboard = UIStoryboard(name: "SearchLocations", bundle: nil)
            var searchViewController = searchStoryboard.instantiateViewControllerWithIdentifier("startSearch") as! SearchViewController
            searchViewController.navigationItem.title = "Find a Location"
            var menuButton = UIBarButtonItem()
            let buttonImg = UIImage(named: "burgerMenu")
            menuButton.setBackgroundImage(buttonImg, forState: .Normal, barMetrics: .Default)
            self.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
            
            //searchViewController.navigationItem.leftBarButtonItem = menuButton
            
            
            //presentViewController(searchViewController, animated: false, completion: nil)
            sideMenuController()?.setContentViewController(searchViewController)
            //            searchViewController.navigationItem.title = "Find a Location"
            //            var menuButton = UIBarButtonItem()
            //            let buttonImg = UIImage(named: "burgerMenu")
            //            menuButton.setBackgroundImage(buttonImg, forState: .Normal, barMetrics: .Default)
            //            searchViewController.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
            break
//            let newLocationStoryboard: UIStoryboard = UIStoryboard(name: "AddNewLocation", bundle: nil)
//            var newLocationViewController = newLocationStoryboard.instantiateViewControllerWithIdentifier("NewLocationController") as! NewLocationController
//            newLocationViewController.navigationItem.title = "Add a Location"
//            var menuButton = UIBarButtonItem()
//            let buttonImg = UIImage(named: "burgerMenu")
//            menuButton.setBackgroundImage(buttonImg, forState: .Normal, barMetrics: .Default)
//            self.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
//            
//            //searchViewController.navigationItem.leftBarButtonItem = menuButton
//            
//            
//            //presentViewController(searchViewController, animated: false, completion: nil)
//            sideMenuController()?.setContentViewController(newLocationViewController)
//            break
//        case 2:

//            let searchStoryboard: UIStoryboard = UIStoryboard(name: "SearchLocations", bundle: nil)
//            var searchViewController = searchStoryboard.instantiateViewControllerWithIdentifier("startSearch") as! SearchViewController
//                searchViewController.navigationItem.title = "Find a Location"
//            var menuButton = UIBarButtonItem()
//            let buttonImg = UIImage(named: "burgerMenu")
//            menuButton.setBackgroundImage(buttonImg, forState: .Normal, barMetrics: .Default)
//            self.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
//            
//                //searchViewController.navigationItem.leftBarButtonItem = menuButton
//            
// 
//            //presentViewController(searchViewController, animated: false, completion: nil)
//            sideMenuController()?.setContentViewController(searchViewController)
////            searchViewController.navigationItem.title = "Find a Location"
////            var menuButton = UIBarButtonItem()
////            let buttonImg = UIImage(named: "burgerMenu")
////            menuButton.setBackgroundImage(buttonImg, forState: .Normal, barMetrics: .Default)
////            searchViewController.navigationItem.setLeftBarButtonItem(menuButton, animated: false)
//                        break
        default:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController4") as! UIViewController
            break
        }
        //sideMenuController()?.setContentViewController(destViewController)
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}