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
    var imageProcessor: CrazyFilter!
    var lastFilter = ""
    let duration = 0.6
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var secondImageView: UIImageView!

    @IBOutlet var originalText: UILabel!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet weak var editFilter: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var filterValue: UISlider!
    
    @IBOutlet var imageToggle: UIButton!
    
    @IBOutlet var btnBlackAndWhite: UIButton!
    
    @IBOutlet weak var btnHalfBrightness: UIButton!
    
    @IBOutlet weak var btnTwiceBrightness: UIButton!
    
    @IBOutlet weak var btnRotateColor: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterValue.continuous = false
        imageView.image = UIImage(named: "scenery")!
        secondImageView.image = UIImage(named: "scenery")!
        
        clearProperties()
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "touch:")
        tapGestureRecognizer.minimumPressDuration = 0
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func clearProperties() {
        secondImageView.alpha = 0

        filterButton.selected = false
        editFilter.selected = false
        editFilter.enabled = false
        editFilter.setTitle("Edit", forState: .Selected)
        
        imageToggle.setTitle("Compare", forState: .Selected)
        imageToggle.selected = false
        imageToggle.enabled = false
        filterValue.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        filterValue.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        originalText.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        originalText.translatesAutoresizingMaskIntoConstraints = false
        btnBlackAndWhite.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        btnHalfBrightness.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        btnTwiceBrightness.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        btnRotateColor.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        
        
        imageProcessor = CrazyFilter(image: imageView.image!,
            dictFilters: ["infernalFilter": Filter(redCoeff: 1.0, greenCoeff: 2, blueCoeff: 2),
                "moreRedFilter": Filter(redCoeff: 2),
                "twiceBrightnessFilter": Filter(redCoeff: 2, greenCoeff: 2, blueCoeff: 2),
                "blackAndWhiteFilter": BlackAndWhiteFilter(commonCoeff: 0.5),
                "rotateColorFilter": RotateColorFilter()])
       
    }
    
    @IBAction func touch(sender: AnyObject) {
        if(sender.state == UIGestureRecognizerState.Began){
            onImageToggle(sender)
        }
        if(sender.state == UIGestureRecognizerState.Ended){
            onImageToggle(sender)
        }
    }
    


    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        if imageToggle.selected {
            crossFadeImage(true)
            hideFlowMenu(self.originalText)
            imageToggle.selected = false
        }
        editFilter.selected = false
        filterButton.selected = false
        hideSecondaryMenu()
        hideFlowMenu(filterValue)
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", secondImageView.image!], applicationActivities: nil)
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
    
    func fixImageOrientation(src:UIImage)->UIImage {
        
        if src.imageOrientation == UIImageOrientation.Up {
            return src
        }
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch src.imageOrientation {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, src.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, src.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, src.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
        case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            CGAffineTransformTranslate(transform, src.size.width, 0)
            CGAffineTransformScale(transform, -1, 1)
            break
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            CGAffineTransformTranslate(transform, src.size.height, 0)
            CGAffineTransformScale(transform, -1, 1)
        case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
            break
        }
        
        let ctx:CGContextRef = CGBitmapContextCreate(nil, Int(src.size.width), Int(src.size.height), CGImageGetBitsPerComponent(src.CGImage), 0, CGImageGetColorSpace(src.CGImage), CGImageAlphaInfo.PremultipliedLast.rawValue)!
        
        CGContextConcatCTM(ctx, transform)
        
        switch src.imageOrientation {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.height, src.size.width), src.CGImage)
            break
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, src.size.width, src.size.height), src.CGImage)
            break
        }
        
        let cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)!
        let img:UIImage = UIImage(CGImage: cgimg)
        
        return img
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if var image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = fixImageOrientation(image)
            imageView.image = image
            secondImageView.image = image
            filteredImage = nil
            if imageToggle.selected {
                crossFadeImage(true)
                hideFlowMenu(self.originalText)
                imageToggle.selected = false
            }
            clearProperties()
            hideSecondaryMenu()
            hideFlowMenu(filterValue)
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
            if imageToggle.selected {
                crossFadeImage(true)
                hideFlowMenu(self.originalText)
                imageToggle.selected = false
            }
            
            hideFlowMenu(filterValue)
            editFilter.selected = false
            
            if (editFilter.selected) {
                onFilterEdit(sender)
            }
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    @IBAction func onChangedFilterValue(sender: UISlider) {
        let value = Float(sender.value)
        var newFilter: Filter!
        switch lastFilter {
            case "infernalFilter":
                newFilter = Filter(redCoeff: 1.0, greenCoeff: 2*2*value, blueCoeff: 2*2*value)
            case "moreRedFilter":
                newFilter = Filter(redCoeff: 2*2*value, greenCoeff: value)
            case "twiceBrightnessFilter":
                newFilter = Filter(redCoeff: 2*2*value, greenCoeff: 2*2*value, blueCoeff: 2*2*value)
            case "blackAndWhiteFilter":
                newFilter = BlackAndWhiteFilter(commonCoeff: value)
            case "rotateColorFilter":
                newFilter = RotateColorFilter(nextColor: value)
            default:
                return
        }
        imageProcessor.changeFilter(lastFilter, newFilter: newFilter)
        let old_image = imageView.image
        imageView.image = filteredImage == nil ? old_image : filteredImage
        filteredImage = imageProcessor.applyFilter(lastFilter)
        crossFadeImage(true, old_image: old_image)
    }
    
    
    @IBAction func onFilterEdit(sender: AnyObject) {
        editFilter.selected = !editFilter.selected
        if editFilter.selected {
            if filterButton.selected {
                onFilter(filterButton)
            }
            if imageToggle.selected {
                crossFadeImage(true)
                hideFlowMenu(self.originalText)
                imageToggle.selected = false
            }
            let bottomConstraint = filterValue.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
            let leftConstraint = filterValue.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
            let rightConstraint = filterValue.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
            
            let heightConstraint = filterValue.heightAnchor.constraintEqualToConstant(44)
            
            showFlowMenu(view, childView: filterValue, bottomConstraint: bottomConstraint, leftConstraint: leftConstraint, rightConstraint: rightConstraint, heightConstraint: heightConstraint, finishAlpha: 0.75)
            
        } else {
            hideFlowMenu(filterValue)
        }
    }
    
    @IBAction func onImageToggle(sender: AnyObject) {
        guard (filteredImage != nil) else {
            return
        }
        editFilter.selected = false
        hideFlowMenu(filterValue)
        imageToggle.selected = !imageToggle.selected
        if imageToggle.selected {
            hideSecondaryMenu()
            filterButton.selected = false
            hideFlowMenu(filterValue)
            editFilter.selected = false
            
            
            let heightConstraint = originalText.heightAnchor.constraintEqualToConstant(44)
            let bottomConstraint = originalText.bottomAnchor.constraintEqualToAnchor(imageView.topAnchor, constant: 44.0)
            let leftConstraint = originalText.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
            let rightConstraint = originalText.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
            
            crossFadeImage(false)
            
            showFlowMenu(imageView, childView: originalText, bottomConstraint: bottomConstraint, leftConstraint: leftConstraint, rightConstraint: rightConstraint, heightConstraint: heightConstraint, finishAlpha: 0.75)
            
        } else {
            crossFadeImage(true)
            
            hideFlowMenu(self.originalText)
        }
    }
    
    @IBAction func rotateColor(sender: AnyObject) {
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("rotateColorFilter", newFilter: RotateColorFilter())
        let old_image = imageView.image
        imageView.image = filteredImage == nil ? old_image : filteredImage
        filteredImage = imageProcessor.applyFilter("rotateColorFilter")
        lastFilter = "rotateColorFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: old_image)
    }
    
    @IBAction func setTwiceBrightness(sender: AnyObject) {
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("twiceBrightnessFilter", newFilter: Filter(redCoeff: 2, greenCoeff: 2, blueCoeff: 2))
        let old_image = imageView.image
        imageView.image = filteredImage == nil ? old_image : filteredImage
        filteredImage = imageProcessor.applyFilter("twiceBrightnessFilter")
        lastFilter = "twiceBrightnessFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: old_image)
    }
    
    @IBAction func setHalfBrightness(sender: AnyObject) {
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("infernalFilter", newFilter: Filter(redCoeff: 1.0, greenCoeff: 2, blueCoeff: 2))
        let old_image = imageView.image
        imageView.image = filteredImage == nil ? old_image : filteredImage
        filteredImage = imageProcessor.applyFilter("infernalFilter")
        lastFilter = "infernalFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: old_image)
    }
    
    @IBAction func setBlackAndWhite(sender: AnyObject) {
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("blackAndWhiteFilter", newFilter: BlackAndWhiteFilter(commonCoeff: 0.5))
        let old_image = imageView.image
        imageView.image = filteredImage == nil ? old_image : filteredImage
        filteredImage = imageProcessor.applyFilter("blackAndWhiteFilter")
        lastFilter = "blackAndWhiteFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: old_image)
    }
    
    @IBAction func redIt(sender: AnyObject) {
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("moreRedFilter", newFilter: Filter(redCoeff: 2))
        let old_image = imageView.image
        imageView.image = filteredImage == nil ? old_image : filteredImage
        filteredImage = imageProcessor.applyFilter("moreRedFilter")
        lastFilter = "moreRedFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: old_image)
    }

    func showSecondaryMenu() {
        editFilter.selected = false
        hideFlowMenu(filterValue)
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        showFlowMenu(view, childView: secondaryMenu, bottomConstraint: bottomConstraint, leftConstraint: leftConstraint, rightConstraint: rightConstraint, heightConstraint: heightConstraint, finishAlpha: 0.75)
    }

    func hideSecondaryMenu() {
        hideFlowMenu(self.secondaryMenu)
    }
    
    func hideFlowMenu(childView: UIView) {
        UIView.animateWithDuration(duration, animations: {
            childView.alpha = 0
            }) { completed in
                if completed == true {
                    childView.removeFromSuperview()
                }
        }
    }
    
    func showFlowMenu(parentView: UIView, childView: UIView, bottomConstraint: NSLayoutConstraint, leftConstraint: NSLayoutConstraint, rightConstraint: NSLayoutConstraint, heightConstraint: NSLayoutConstraint, finishAlpha: CGFloat) {
        parentView.addSubview(childView)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        parentView.layoutIfNeeded()
        
        childView.backgroundColor = UIColor.blackColor()
        childView.alpha = 0
        UIView.animateWithDuration(duration) {
            childView.alpha = finishAlpha
        }
        
    }
    
    func crossFadeImage(is_show: Bool, old_image: UIImage! = nil) {
        if (is_show) {
            secondImageView.alpha = 0
            secondImageView.image = filteredImage
            UIView.animateWithDuration(duration, animations: {
                self.secondImageView.alpha = 1.0
                }){ completed in
                    if (completed == true && old_image != nil) {
                        self.imageView.image = old_image
                    }
        }
        
        } else {
            secondImageView.alpha = 1.0
            UIView.animateWithDuration(duration) {
                self.secondImageView.alpha = 0.0
            }

        }
        
    }

}

