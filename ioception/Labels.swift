//
//  Labels.swift
//  ioception
//
//  Created by Luvsandondov Lkhamsuren on 4/11/16.
//  Copyright © 2016 lkhamsurenl. All rights reserved.
//

import Foundation

// Labels class generates sorted (name, score) pairs.
class Labels : CustomStringConvertible {
    var labels: [(String, Double)]
    init(inputJson: String) {
        // Function used for reverse sorting dictionary by values.
        let byValueReverse = {
            (elem1:(key: String, val: Double), elem2:(key: String, val: Double))->Bool in
            if elem1.val < elem2.val {
                return false
            } else {
                return true
            }
        }
        
        func parseJsonLabels(inputJson: String) -> [String: Double] {
            // parse JSON to create list of values.
            func parseJson(anyObj:AnyObject) -> [String: Double]{
                
                var list:[String: Double] = [:]
                
                if anyObj is Array<AnyObject> {
                    for json in anyObj as! Array<AnyObject>{
                        let name = (json["name"] as AnyObject? as? String) ?? "" // to get rid of null
                        let score  =  (json["score"]  as AnyObject? as? String) ?? "0.0"
                        
                        // Show score as percent, with rounded 3 digits precision.
                        list[name] = Double(round(100 * 1000 * Double(score)!)/1000)
                    }
                }
                return list
            }
            
            // convert String to NSData
            let data: NSData = inputJson.dataUsingEncoding(NSUTF8StringEncoding)!
            
            var labels: [String: Double] = [:]
            
            // convert NSData to 'AnyObject'
            do {
                if let anyObj: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) {
                    // convert 'AnyObject' to Array<Business>
                    labels = parseJson(anyObj!)
                }
                
            } catch let error as NSError {
                print("Error: \(error)")
            }
            return labels
        }
        
        labels = parseJsonLabels(inputJson).sort(byValueReverse)
    }
    
    var description: String {
        // Create nice readable form sorted labels for visual display.
        var text = ""
        for (name, score) in labels {
            text += "\(name): \(score)\n"
        }
        return text
    }
    
}