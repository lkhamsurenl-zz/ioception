//
//  ImageUtils.swift
//  ioception
//
//  Created by Luvsandondov Lkhamsuren on 4/11/16.
//  Copyright © 2016 lkhamsurenl. All rights reserved.
//

import UIKit
import Foundation

// Given a image and width, resize image to new width, while maintaining the proportion.
func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}