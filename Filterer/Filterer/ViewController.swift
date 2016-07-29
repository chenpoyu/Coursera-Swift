//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var filteredImage: UIImage?
    var originalImage: UIImage?
    var imageFilterProcess: ImageFilterProcessor?
    
    var grayscaleImage: UIImage?
    var contrastImage: UIImage?
    var blurryImage: UIImage?
    var hmirrorImage: UIImage?
    var vmirrorImage: UIImage?
    var effect = 0
    var images: [UIImage] = []
    var defaultIntensity:Float = 1.5
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var secondaryView: UIImageView!
    
    @IBOutlet var intensityMenu: UIView!
    @IBOutlet var secondaryMenu: UIScrollView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
//    @IBOutlet var originalButton: UIButton!
//    @IBOutlet var grayscaleButton: UIButton!
//    @IBOutlet var contrastButton: UIButton!
//    @IBOutlet var blurryButton: UIButton!
//    @IBOutlet var hmirrorButton: UIButton!
//    @IBOutlet var vmirrorButton: UIButton!
    
    @IBOutlet var intensitySilder: UISlider!
    
    @IBOutlet var textView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu = UIScrollView(frame: view.bounds)
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.contentSize = CGSize.init(width: imageView.bounds.width, height: 44)
        
        intensityMenu = UIView(frame: view.bounds)
        intensityMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        intensityMenu.translatesAutoresizingMaskIntoConstraints = false
        
        originalImage = imageView.image
        filteredImage = imageView.image
        
        compareButton.enabled = false
        secondaryView.alpha = 0
        textView.alpha = 0
        
        intensitySilder = UISlider(frame: CGRect(x: 5, y: 2, width: intensityMenu.bounds.width - 10, height: 40 ))
        intensitySilder.addTarget(self, action: "onIntensitySlider:", forControlEvents: UIControlEvents.PrimaryActionTriggered)
        intensitySilder.maximumValue = 3
        intensitySilder.minimumValue = 0
        intensitySilder.value = defaultIntensity
        intensityMenu.addSubview(intensitySilder)
    }
    
    // MARK: tap the image
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        textView.alpha = 1.0
        imageView.image = originalImage
        super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        textView.alpha = 0
        imageView.image = filteredImage
        super.touchesEnded(touches, withEvent:event)
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
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
        dismissViewControllerAnimated(false, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.originalImage = image
            self.filteredImage = image
            self.imageView.image = filteredImage
            self.compareButton.enabled = false
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            hideIntensityMenu()
            editButton.selected = false
            
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        imageFilterProcess = ImageFilterProcessor(image: originalImage!)
        grayscaleImage = imageFilterProcess!.doFilter("Grayscale", factor: intensitySilder.value)
        contrastImage = imageFilterProcess!.doFilter("Contrast", factor: intensitySilder.value)
        blurryImage = imageFilterProcess!.doFilter("Blurry", factor: intensitySilder.value)
        hmirrorImage = imageFilterProcess!.doFilter("HMirror")
        vmirrorImage = imageFilterProcess!.doFilter("VMirror")
        
        images.removeAll()
        images.append(originalImage!)
        images.append(grayscaleImage!)
        images.append(contrastImage!)
        images.append(blurryImage!)
        images.append(hmirrorImage!)
        images.append(vmirrorImage!)
        
        for index in 0...images.count - 1 {
            let tmpBtn = UIButton(frame: CGRect(x: 5 + (45 * index), y: 2, width: 40, height: 40 ))
            tmpBtn.setImage(images[index], forState: .Normal)
            tmpBtn.addTarget(self, action: "changeImage:", forControlEvents: UIControlEvents.TouchUpInside)
            tmpBtn.tag = index
            self.secondaryMenu.addSubview(tmpBtn)
        }
                self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
//    @IBAction func onOriginal(sender: AnyObject) {
//        changeImage(originalImage!)
//    }
//    
//    @IBAction func onGrayscale(sender: AnyObject) {
//        changeImage(grayscaleImage!)
//    }
//    
//    @IBAction func onContrast(sender: AnyObject) {
//        changeImage(contrastImage!)
//    }
//    
//    @IBAction func onBlurry(sender: AnyObject) {
//        changeImage(blurryImage!)
//    }
//
//    @IBAction func onHMirror(sender: AnyObject) {
//        changeImage(hmirrorImage!)
//    }
    
    func changeImage(sender: UIButton) {
        filteredImage = images[sender.tag]
        effect = sender.tag
        imageView.image = filteredImage
//        imageFilterProcess = ImageFilterProcessor(image: filteredImage!)
        compareButton.enabled = true
    }
    
    // MARK: Edit
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected) {
            hideIntensityMenu()
            sender.selected = false
        } else {
            hideSecondaryMenu()
            filterButton.selected = false
            
            showIntensityMenu()
            sender.selected = true
        }
    }
    
    func showIntensityMenu() {
        view.addSubview(intensityMenu)
        
        let bottomConstraint = intensityMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = intensityMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = intensityMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = intensityMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        imageFilterProcess = ImageFilterProcessor(image: imageView.image!)
        
        self.intensityMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.intensityMenu.alpha = 1.0
        }
    }
    
    func hideIntensityMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.intensityMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.intensityMenu.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onIntensitySlider(sender: UISlider) {
        let currentValue = Float(sender.value)
        if effect == 0 {
            filteredImage = originalImage
        } else if effect == 1 {
            filteredImage = imageFilterProcess!.doFilter("Grayscale", factor: currentValue)
        } else if effect == 2 {
            filteredImage = imageFilterProcess!.doFilter("Contrast", factor: currentValue)
        } else if effect == 3 {
            filteredImage = imageFilterProcess!.doFilter("Blurry", factor: currentValue)
        } else if effect == 4 {
            filteredImage = hmirrorImage
        } else if effect == 5 {
            filteredImage = vmirrorImage
        }
        imageView.image = filteredImage
    }
    
    // MARK: Compare
    @IBAction func onCompare(sender: UIButton) {
        if (sender.selected) {
            UIView.animateWithDuration(0.4, animations: {
                self.textView.alpha = 0
                self.secondaryView.alpha = 0
                }) { completed in
                    if completed == true {
                        sender.selected = false
                    }
            }
        } else {
            secondaryView.image = originalImage
            UIView.animateWithDuration(0.4, animations: {
                self.textView.alpha = 1.0
                self.secondaryView.alpha = 1.0
                }) { completed in
                    if completed == true {
                        sender.selected = true
                    }
            }
        }
    }
}

