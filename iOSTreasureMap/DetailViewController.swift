//
//  DetailViewController.swift
//  iOSTreasureMap
//
//  Created by Julia Dullin on 26.05.15.
//  Copyright (c) 2015 TreasureMap. All rights reserved.
//

// image scroll view tutorial: http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift

import Foundation

class DetailViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    //navigation stuff
    @IBOutlet weak var pageScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UINavigationItem!
    var rootViewController = MapViewController()

    //for location descriptions
    @IBOutlet weak var locationDetails: UILabel!
    @IBOutlet weak var locationDescription: UILabel!
    var didTapPin: GMSMarker!
    var detailsFromRootView: Location!

    //variables for the images
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    //upload photos
    @IBOutlet weak var uploadPhotoButton: UIButton!
    var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView?.center
        //self.view.bringSubviewToFront(navigationBar)
        var street = detailsFromRootView.address?.valueForKey("street") as! String
        var zip = detailsFromRootView.address?.valueForKey("zipcode") as! String
        var city = detailsFromRootView.address?.valueForKey("city") as! String
        var category = detailsFromRootView.category!.valueForKey("name") as! String
        var description = detailsFromRootView.details?.valueForKey("description") as? String
        
        //toolbar.topItem?.title = detailsFromRootView.details!.valueForKey("name") as? String
        
        //locationDetails.font = UIFont(name: "STHeitiTC-Light", size: 12)
        locationDetails.text = "Address:" + "\n" +  "\(street)" + "\n" + "\(zip)" + "\n" + "\(city)"
        
        //locationDescription.font = UIFont(name: "STHeitiTC-Light", size: 12)
        locationDescription.text = "\(category)" + "\n" + "\(description)"
        locationDescription.adjustsFontSizeToFitWidth = true
        
        var photos = detailsFromRootView.details!.valueForKey("pictures") as! NSArray
        for(var x=0; x<photos.count; x++){
            var photoUrl = NSURL(string: photos[x] as! String)
            var photoData = NSData(contentsOfURL: photoUrl!)
            var photo = UIImage(data: photoData!, scale: 5)
            pageImages.append(photo!)
        }

        //setting up Page Control
        let pageCount = pageImages.count
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount

        //fill with nil objects as placeholders since no pages have been loaded yet
        //otherwise we would get an array index out of bounds exception
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        //setting up the size of the image scrollView
        let pagesScrollViewSize = imageScrollView.frame.size
        imageScrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count),
            height: pagesScrollViewSize.height)
        //hide native scrollbars of scroll view
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        showVisiblePagesOnController()
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        showVisiblePagesOnController()
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func uploadPhotos(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = .Camera
        
        presentViewController(imagePicker!, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        let detailStoryboard = UIStoryboard(name: "DetailView", bundle: nil)
        let photoView = detailStoryboard.instantiateViewControllerWithIdentifier("photoTaken") as! ImageViewController
        photoView.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.presentViewController(photoView, animated: true, completion: nil)
        
    }
    
    func showVisiblePagesOnController(){
        // First, determine which page is currently visible
        let pageWidth = imageScrollView.frame.size.width
        let page = Int(floor((imageScrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadSinglePage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    /**
    the page views are loaded lazily, which means they are only loaded when they're needed and get 
    deleted afterwards. This way we only take up as much memory as we need in case there are 
    locations with lots of images
    **/
    func loadSinglePage(page: Int){
        //if page is out of range, do nothing
        if page < 0 || page >= pageImages.count{
        return
        }
        //if the page view has not been loaded, load it
        if let pageView = pageViews[page] {
        }
        else{
            //set size of the page to the same size as imageScrollView
            var frame = imageScrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            imageScrollView.addSubview(newPageView)
            
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int){
        //if page is out of range, do nothing
        if page < 0 || page >= pageImages.count{
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }

    }
    
}