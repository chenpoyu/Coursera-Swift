//
//  DetailViewController.swift
//  BusinessCard
//
//  Created by poyuchen on 2016/12/13.
//  Copyright © 2016年 poyuchen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate  {
    
    @IBOutlet var pictureView: UIImageView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var phoneText: UITextField!
    @IBOutlet var addressText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var descriptionText: UITextView!
    
    var scrollView: UIScrollView!
    var newImageView: UIImageView!
    var timeStamp: NSDate!

    var detailItem: Card? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            timeStamp = detail.timeStamp
            if let nameText = self.nameText {
                nameText.text = detail.name
            }
            if let phoneText = self.phoneText {
                phoneText.text = detail.phone
            }
            if let addressText = self.addressText {
                addressText.text = detail.address
            }
            if let pictureView = self.pictureView {
                pictureView.image = UIImage(data:detail.picture!, scale:1.0)
            }
            if let descriptionText = self.descriptionText {
                descriptionText.text = detail.desc
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        self.descriptionText.layer.borderWidth = 0.5;
        self.descriptionText.layer.borderColor = UIColor( red: 0, green: 0, blue: 0, alpha: 1.0 ).CGColor;
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let tapViewGestureRecognizer = UITapGestureRecognizer(target:self, action:"imageTapped")
        pictureView.addGestureRecognizer(tapViewGestureRecognizer)
        
        self.nameText.delegate = self;
        self.phoneText.delegate = self;
        self.addressText.delegate = self;
        self.emailText.delegate = self;
        self.descriptionText.delegate = self;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        //        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
        //            if view.frame.origin.y != 0 {
        //                self.view.frame.origin.y += keyboardSize.height
        //            }
        //        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    @IBAction func deleteImage(sender: AnyObject) {
        pictureView.image = nil
    }
    
    @IBAction func uploadImage(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pictureView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: show card picture can zoom
    func imageTapped() {
        if pictureView.image != nil {
            newImageView = UIImageView(image: pictureView.image)
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = .whiteColor()
            newImageView.contentMode = .ScaleAspectFit
            newImageView.userInteractionEnabled = true
            newImageView.frame.size = pictureView.image!.size
            let tap = UITapGestureRecognizer(target: self, action: "dismissFullscreenImage:")
            newImageView.addGestureRecognizer(tap)
            
            scrollView = UIScrollView(frame: view.bounds)
            scrollView.backgroundColor = UIColor.blackColor()
            scrollView.contentSize = newImageView.bounds.size
            scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            scrollView.delegate = self
            //            scrollView.minimumZoomScale = 0.1
            //            scrollView.maximumZoomScale = 4.0
            //            scrollView.zoomScale = 1.0
            setZoomScale()
            
//            setupGestureRecognizer()
            
            scrollView.addSubview(newImageView)
            view.addSubview(scrollView)
        }
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        scrollView.removeFromSuperview()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return newImageView
    }
    
    func setZoomScale() {
        if newImageView != nil && scrollView != nil {
            let imageViewSize = newImageView.bounds.size
            let scrollViewSize = scrollView.bounds.size
            let widthScale = scrollViewSize.width / imageViewSize.width
            let heightScale = scrollViewSize.height / imageViewSize.height
            
            scrollView.minimumZoomScale = min(widthScale, heightScale)
            scrollView.zoomScale = 1.0
        }
    }
    
    // when rotate the screen resize the picture
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = newImageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    // double click let the picture to the max size
//    func setupGestureRecognizer() {
//        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
//        doubleTap.numberOfTapsRequired = 2
//        scrollView.addGestureRecognizer(doubleTap)
//    }
//    
//    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
//        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
//            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
//        } else {
//            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
//        }
//    }
}

