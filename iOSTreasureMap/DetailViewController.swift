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
    //@IBOutlet weak var backButton: UIBarButtonItem!
    var rootViewController : MapViewController?
    @IBOutlet weak var detailScrollView: UIScrollView!
    
    //for location descriptions
    @IBOutlet weak var locationDetails: UILabel!
    @IBOutlet weak var locationDescription: UITextView!
    var didTapPin: GMSMarker!
    var detailsFromRootView: Location!
    
    
    //variables for the images
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    var currentPage: Int?
    var index = 0
    
    //upload photos
    @IBOutlet weak var uploadPhotoButton: UIButton!
    var takePhoto:  UIImagePickerController?
    var pickImage: UIImagePickerController?
    var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uploadPhotoButton.titleLabel?.text = "Upload Photos"
        uploadPhotoButton.titleLabel?.textColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        self.detailScrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height)
        self.detailScrollView.scrollEnabled = true

        
        //self.view.bringSubviewToFront(navigationBar)
        var street = detailsFromRootView.address!.valueForKey("street") as! String
        var zip = detailsFromRootView.address!.valueForKey("zipcode") as! String
        var city = detailsFromRootView.address!.valueForKey("city") as! String
        var category = detailsFromRootView.category!.valueForKey("name") as! String
        var description = detailsFromRootView.details!.valueForKey("description") as? String
        //toolbar.topItem?.title = detailsFromRootView.details!.valueForKey("name") as? String
        //locationDetails.font = UIFont(name: "STHeitiTC-Light", size: 12)
        locationDetails.text = "Address:" + "\n" +  "\(street)" + "\n" + "\(zip)" + "\n" + "\(city)"
        
        //locationDescription.font = UIFont(name: "STHeitiTC-Light", size: 12)
        locationDescription.text = "\(category)" + "\n" + "\(description)"
        locationDescription.editable = false
        
        //self.view.bringSubviewToFront(toolbar)
       
            
            //detailsFromRootView.details!.valueForKey("name") as? String
        
        
        if let photos = detailsFromRootView.details?.valueForKey("pictures") as? NSArray{
            for(var x = 0; x<photos.count; x++){
                if let photoUrl = NSURL(string: (photos[x] as! String)){
                    if let data = NSData(contentsOfURL: photoUrl, options: nil, error: NSErrorPointer()){
                        var photo = UIImage(data: data, scale: 5)
                        pageImages.append(photo!)
                        //show the first photo again
                    }
                }
            }
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
        self.dismissViewControllerAnimated(false, completion: nil)
    
    }
    
    
    
    
    @IBAction func uploadPhotos(sender: UIButton) {
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default){
            UIAlertAction in
            self.takePhoto = UIImagePickerController()
            self.takePhoto?.delegate = self
            self.takePhoto?.sourceType = .Camera
            
            self.presentViewController(self.takePhoto!, animated: true, completion: nil)
        }
        var libraryAction = UIAlertAction(title: "Choose Photo from Library", style: UIAlertActionStyle.Default){
            UIAlertAction in
            self.pickImage = UIImagePickerController()
            self.pickImage?.delegate = self
            self.pickImage?.sourceType = .PhotoLibrary
            
            self.presentViewController(self.pickImage!, animated: true, completion: nil)
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.view.backgroundColor = UIColor(red: 53, green: 53, blue: 53, alpha: 1)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let detailStoryboard = UIStoryboard(name: "DetailView", bundle: nil)
        let imageViewController = detailStoryboard.instantiateViewControllerWithIdentifier("photoTaken") as! ImageViewController
        
        if let picker = pickImage{
            pickImage!.dismissViewControllerAnimated(true, completion: nil)
            imageViewController.photoFromRootView = info[UIImagePickerControllerOriginalImage] as? UIImage
            imageViewController.mediaTypeFromRootView = info[UIImagePickerControllerMediaType] as? NSString
            imageViewController.photoData = info
            imageViewController.id = detailsFromRootView.id!
            imageViewController.location = detailsFromRootView!
            imageViewController.rootViewController = self
            self.presentViewController(imageViewController, animated: true, completion: nil)
        }
        
        if let picker = takePhoto{
            takePhoto!.dismissViewControllerAnimated(true, completion: nil)
            imageViewController.photoFromRootView = info[UIImagePickerControllerOriginalImage] as? UIImage
            imageViewController.mediaTypeFromRootView = info[UIImagePickerControllerMediaType] as? NSString
            imageViewController.photoData = info
            imageViewController.id = detailsFromRootView.id!
            imageViewController.location = detailsFromRootView!
            imageViewController.rootViewController = self
            self.presentViewController(imageViewController, animated: true, completion: nil)
        }
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
        for index; index < firstPage; ++index {
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
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = imageScrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            imageScrollView.addSubview(newPageView)
            pageViews[page] = newPageView
            currentPage = page

            
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
    
    @IBAction func viewTapped(sender: AnyObject) {
        var currentImage : UIImage = pageImages[index]
        
        let detailStoryboard = UIStoryboard(name: "DetailView", bundle: nil)
        let largeImage = detailStoryboard.instantiateViewControllerWithIdentifier("largeImage") as! LargeImage
        largeImage.imageFromDetailView = currentImage
//        largeImage.toolbar.title = detailsFromRootView.details!.valueForKey("name") as? String
        self.presentViewController(largeImage, animated: true, completion: nil)
    }
    
}

class LargeImage: UINavigationController{

    var imageFromDetailView: UIImage?
    @IBOutlet weak var image: UIImageView!
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = imageFromDetailView
        image.contentMode = .ScaleAspectFit
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}












