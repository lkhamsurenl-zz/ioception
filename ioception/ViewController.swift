//
//  ViewController.swift
//  ioception
//
//  Created by Luvsandondov Lkhamsuren on 4/7/16.
//  Copyright © 2016 lkhamsurenl. All rights reserved.
//

import UIKit
import SwiftClient

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    
    /***************                   Camera and Album                           *********************/
    @IBOutlet var photoButton: UIButton!
    @IBAction func onPhotoButton(sender: UIButton) {
        // display a controller to show the camera or album to select an image.
        // Craete an action sheet with options: camera, album, and cancel.
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        // Camera action sheet.
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {
            action in
            self.showCamera()
        }))
        // Album action sheet.
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: {
            action in
            self.showAlbum()
        }))
        // Cancel action sheet.
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        // Create an image picker controller, delegated to the self controller.
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        // Display the controller to the user.
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        // Create an image picker controller, this time for the album.
        let albumPicker = UIImagePickerController()
        albumPicker.delegate = self
        albumPicker.sourceType = .PhotoLibrary
        
        // Display the controller to the user.
        presentViewController(albumPicker, animated: true, completion: nil)
    }
    
    // Function handles the process, when finished picking the image.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        // Change the image displayed on the screen.
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getNutritionalInformation(item: String) {
        
        let client = Client()
            .baseUrl("https://api.nutritionix.com/v1_1/search/\(item)?fields=item_name%2Citem_id%2Cbrand_name%2Cnf_calories%2Cnf_total_fat&appId=b477e8aa&appKey=1cab4bd6f3ce19e838516becca446ed9")
            .onError({error in
                print("api call error: \(error)")
                self.showAlertWithMessage("Could not connect to the server.\nPlease try agiain.")
            });
        
        client.get("/")
            .end({(res:Response) -> Void in
                print(res.text)
            })
    }
    /***************                   Classification                           *********************/
    @IBOutlet var classifyButton: UIButton!
    @IBAction func onClassifyButton(sender: UIButton) {
        if !classifyButton.selected && imageView.image != nil {
            let image = imageView.image
            // Resize the input image to smaller size for better IO utilization.
            let resizedImage = resizeImage(image!, newWidth: 200)
            // Send RESTful API request to the localhost to classify the given image.
            uploadImage(resizedImage)
            // Display second view with resized image to indicate classifying image.
            self.showSecondView(resizedImage)
        }
        classifyButton.selected = !classifyButton.selected
    }
    
    func uploadImage(image:UIImage) {
        let imageData:NSData = UIImageJPEGRepresentation(image, 1.0)!
        
        let client = Client()
            .baseUrl("http://lkhamsurenl-macbook-pro.local:5000")
            .onError({error in
                print("api call error: \(error)")
                self.showAlertWithMessage("Could not connect to the server.\nPlease try agiain.")
            });
        
        client.post("/upload")
            .attach("image", imageData, "\(image.hashValue).jpg")
            .end({(res:Response) -> Void in
                self.displayLabels(res.text)
            })
    }
    
    func showAlertWithMessage(text: String) {
        // Display alert control should happen in the main thread.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Show to the user.
            let alertController = UIAlertController(title: "Image labels", message:text, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,
                handler: { (alert: UIAlertAction!) in
                    self.hideSecondView()
                    self.classifyButton.selected = false
                    // self.getNutritionalInformation("apple")
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    // displayLabels function will parse input str to create [name: score] pairs and show dialog to the 
    // user on top of the image.
    func displayLabels(str: String?) {
        // Remove extra front \" and end \"\n.
        let strippedString = str!.substringWithRange(str!.startIndex.advancedBy(1)..<str!.endIndex.advancedBy(-2))
        
        // Replace \\\" by \".
        let newString = strippedString.stringByReplacingOccurrencesOfString("\\\"", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let labels = Labels(inputJson: newString)
        
        self.showAlertWithMessage(labels.description)
    }
    
    @IBOutlet var secondView: UIView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet var secondImageView: UIImageView!
    // Show the second view with transparent background.
    func showSecondView(image: UIImage) {
        view.addSubview(secondView)
        
        // Ensure secondary view lay on top of full image.
        secondView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = secondView.topAnchor.constraintEqualToAnchor(view.topAnchor)
        let bottomConstraint = secondView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        let leftConstraint = secondView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, topConstraint])
        
        // Let view know that it needs to update its view.
        view.layoutIfNeeded()
        
        // Gradually increase the alpha term to make the 2ary menu transparent.
        self.secondView.alpha = 0
        UIView.animateWithDuration(0.5) {
            self.secondView.alpha = 0.7
        }
        // Display the smaller image on the second screen.
        self.secondImageView.image = image
        
        self.activityIndicatorView.startAnimating()
    }
    
    // Hide the secondary view.
    func hideSecondView() {
        // Remove the secondary view by gradually decreasing the alpha term and remove from the super view when done.
        UIView.animateWithDuration(0.5, animations: {
            self.secondView.alpha = 0.0
        }) { completed in
            if completed == true {
                // 1. Remove the secondView from the screen.
                self.secondView.removeFromSuperview()
                // 2. Stop activity indicator animation.
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.image = UIImage(named: "aurora")
    }
}

