//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

    var items: [String] = ["original", "bright", "black", "red", "infernal", "rotate"]
    var filters: [String: UIButton] = [:]
    var is_dragging = false
    var filteredImage: UIImage?
    var originalImage: UIImage?
    var imageProcessor: CrazyFilter!
    var height = 0
    var width = 0
    var lastFilter = ""
    let duration = 0.6
    var last_value: Float32 = 0.0
    static var numOfCalculate: Int = -1
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var secondImageView: UIImageView!

    @IBOutlet var originalText: UILabel!
    
    @IBOutlet var bottomMenu: UIView!
    
    @IBOutlet var filterMenu: UICollectionView!
    @IBOutlet weak var editFilter: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var filterValue: UISlider!
    
    @IBOutlet var imageToggle: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterMenu.multipleTouchEnabled = true
        //filterValue.continuous = false
        originalImage = UIImage(named: "scenery")!
        imageView.image = originalImage
        secondImageView.image = originalImage
        
        clearProperties()
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "touch:")
        tapGestureRecognizer.minimumPressDuration = 0
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
     }
    
    func clearProperties() {
        let  rgb = RGBAImage(image: imageView.image!)
        self.width = (rgb?.width)!
        self.height = (rgb?.height)!
    
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
        filterMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        filterMenu.translatesAutoresizingMaskIntoConstraints = false
        originalText.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        originalText.translatesAutoresizingMaskIntoConstraints = false
          
        
        imageProcessor = CrazyFilter(image: imageView.image!,
            dictFilters: ["infernalFilter": Filter(redCoeff: 1.0, greenCoeff: 2, blueCoeff: 2),
                "moreRedFilter": Filter(redCoeff: 2),
                "twiceBrightnessFilter": Filter(redCoeff: 2, greenCoeff: 2, blueCoeff: 2),
                "blackAndWhiteFilter": BlackAndWhiteFilter(commonCoeff: 0.5),
                "rotateColorFilter": RotateColorFilter()])
        
        select_filter("original")
       
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MyCollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        let btnName = self.items[indexPath.item]
        cell.myBtn.setBackgroundImage(UIImage(named: btnName)!, forState: .Normal)
        cell.myBtn.setBackgroundImage(UIImage(named: "selected_\(btnName)")!, forState: .Selected)
        switch btnName{
            case "original":
                cell.myBtn.selected = true
                cell.myBtn.addTarget(self, action: "setOriginal", forControlEvents: .TouchUpInside)
                break
            case "bright":
                cell.myBtn.addTarget(self, action: "setTwiceBrightness", forControlEvents: .TouchUpInside)
                break
            case "black":
                cell.myBtn.addTarget(self, action: "setBlackAndWhite", forControlEvents: .TouchUpInside)
                break
            case "red":
                cell.myBtn.addTarget(self, action: "redIt", forControlEvents: .TouchUpInside)
                break
            case "infernal":
                cell.myBtn.addTarget(self, action: "setInfernal", forControlEvents: .TouchUpInside)
                break
            case "rotate":
                cell.myBtn.addTarget(self, action: "rotateColor", forControlEvents: .TouchUpInside)
                break
            
            default:
                break
        }
        filters[btnName] = cell.myBtn
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
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
        hideFilterMenu()
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImage = fixImageOrientation(image)
            imageView.image = originalImage
            secondImageView.image = originalImage
            filteredImage = nil
            if imageToggle.selected {
                crossFadeImage(true)
                hideFlowMenu(self.originalText)
                imageToggle.selected = false
            }
            clearProperties()
            hideFilterMenu()
            hideFlowMenu(filterValue)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideFilterMenu()
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
            showFilterMenu()
            sender.selected = true
        }
    }
    

    func recalculateValue(value: Float32) {
        ViewController.numOfCalculate++
        let idCalculate = ViewController.numOfCalculate
        dispatch_async(queue, {
//            print("num = \(ViewController.numOfCalculate)")

            self.last_value = value
            
            var newFilter: Filter!
            
            switch self.lastFilter {
            case "infernalFilter":
                newFilter = Filter(redCoeff: 1.0, greenCoeff: 2*2*value, blueCoeff: 2*2*value)
            case "moreRedFilter":
                newFilter = Filter(redCoeff: 2*2*value)
            case "twiceBrightnessFilter":
                newFilter = Filter(redCoeff: 2*2*value, greenCoeff: 2*2*value, blueCoeff: 2*2*value)
            case "blackAndWhiteFilter":
                newFilter = BlackAndWhiteFilter(commonCoeff: value)
            case "rotateColorFilter":
                newFilter = RotateColorFilter(nextColor: value)
            default:
                return
            }
            self.imageProcessor.changeFilter(self.lastFilter, newFilter: newFilter)
            self.filteredImage = self.imageProcessor.applyFilter(idCalculate, nameOfFilter: self.lastFilter)
            dispatch_async(dispatch_get_main_queue(), {
//                print("id = \(idCalculate), num = \(ViewController.numOfCalculate)")

                if (idCalculate == ViewController.numOfCalculate) {
                    ViewController.numOfCalculate = -1
                    self.crossFadeImage(true, old_image: self.originalImage)
                }
                
            })
        })

    }
    
    
    @IBAction func touchUpOutsideValue(sender: UISlider) {
        recalculateValue(Float32(sender.value))
    }
    
    @IBAction func touchUpInsideValue(sender: UISlider) {
        recalculateValue(Float32(sender.value))
    }
    
    @IBAction func touchDownValue(sender: UISlider) {
        recalculateValue(Float32(sender.value))
    }

    @IBAction func onChangedFilterValue(sender: UISlider) {
        let value = Float32(sender.value)
        let delta_value = value - last_value
        
        if abs(delta_value) > 0.000000015 * Float32(width) * Float32(height) {
            recalculateValue(value)
        }
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
            hideFilterMenu()
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
    
    func select_filter(selected_name: String){
        for it in items {
            if it != selected_name {
                filters[it]?.selected = false
            }
            else {
                filters[it]?.selected = true
            }
        }
        
    }
    
    @IBAction func setOriginal() {
        select_filter("original")
        filterValue.setValue(0.5, animated: true)
        imageView.image = filteredImage == nil ? originalImage : filteredImage
        filteredImage = originalImage
        lastFilter = ""
        imageToggle.enabled = false
        editFilter.enabled = false
        
        crossFadeImage(true, old_image: originalImage)
    }
    
    @IBAction func rotateColor() {
        select_filter("rotate")
        filters["rotate"]?.selected = true
        
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("rotateColorFilter", newFilter: RotateColorFilter())
        imageView.image = filteredImage == nil ? originalImage : filteredImage
        filteredImage = imageProcessor.applyFilter(ViewController.numOfCalculate, nameOfFilter: "rotateColorFilter")
        lastFilter = "rotateColorFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: originalImage)
    }
    
    @IBAction func setTwiceBrightness() {
        select_filter("bright")
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("twiceBrightnessFilter", newFilter: Filter(redCoeff: 2, greenCoeff: 2, blueCoeff: 2))
        imageView.image = filteredImage == nil ? originalImage : filteredImage
        filteredImage = imageProcessor.applyFilter(ViewController.numOfCalculate, nameOfFilter: "twiceBrightnessFilter")
        lastFilter = "twiceBrightnessFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: originalImage)
    }
    
    @IBAction func setInfernal() {
        select_filter("infernal")
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("infernalFilter", newFilter: Filter(redCoeff: 1.0, greenCoeff: 2, blueCoeff: 2))
        imageView.image = filteredImage == nil ? originalImage : filteredImage
        filteredImage = imageProcessor.applyFilter(ViewController.numOfCalculate, nameOfFilter: "infernalFilter")
        lastFilter = "infernalFilter"
        imageToggle.enabled = true
        editFilter.enabled = true

        crossFadeImage(true, old_image: originalImage)
    }
    
    
    @IBAction func setBlackAndWhite() {
        select_filter("black")
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("blackAndWhiteFilter", newFilter: BlackAndWhiteFilter(commonCoeff: 0.5))
        imageView.image = filteredImage == nil ? originalImage : filteredImage
        filteredImage = imageProcessor.applyFilter(ViewController.numOfCalculate, nameOfFilter: "blackAndWhiteFilter")
        lastFilter = "blackAndWhiteFilter"
        imageToggle.enabled = true
        editFilter.enabled = true
        
        crossFadeImage(true, old_image: originalImage)
    }


    @IBAction func redIt() {
        select_filter("red")
        filterValue.setValue(0.5, animated: true)
        imageProcessor.changeFilter("moreRedFilter", newFilter: Filter(redCoeff: 2))
        imageView.image = filteredImage == nil ? originalImage : filteredImage
        filteredImage = imageProcessor.applyFilter(ViewController.numOfCalculate, nameOfFilter: "moreRedFilter")
        lastFilter = "moreRedFilter"
        imageToggle.enabled = true
        editFilter.enabled = true
        
        crossFadeImage(true, old_image: originalImage)
    }
    
    func showFilterMenu() {
        editFilter.selected = false
        hideFlowMenu(filterValue)
        let bottomConstraint = filterMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = filterMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = filterMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = filterMenu.heightAnchor.constraintEqualToConstant(64)
        
        showFlowMenu(view, childView: filterMenu, bottomConstraint: bottomConstraint, leftConstraint: leftConstraint, rightConstraint: rightConstraint, heightConstraint: heightConstraint, finishAlpha: 0.75)
    }

    func hideFilterMenu() {
        hideFlowMenu(self.filterMenu)
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
            self.imageView.image = secondImageView.image
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
            self.imageView.image = originalImage
            UIView.animateWithDuration(duration) {
                self.secondImageView.alpha = 0.0
            }

        }
        
    }

}

