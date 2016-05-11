//
//  Nutrition.swift
//  ioception
//
//  Created by Luvsandondov Lkhamsuren on 5/10/16.
//  Copyright © 2016 lkhamsurenl. All rights reserved.
//

import Foundation
import SwiftyJSON

// Nutrition class generates (nutrient, value) pairs.
class Nutrition : CustomStringConvertible {
    
    var nutrients: [String: Double] = [:]
    
    init(inputJson: JSON) {
        
        for (_, nutrient): (String, JSON) in inputJson {
            switch nutrient["name"].string! {
            case "Water": // Water in grams.
                nutrients["Water"] = nutrient["value"].double!
            case "Energy": // Energy in calories.
                nutrients["Energy"] = nutrient["value"].double!
            case "Protein": // Protein in grams.
                nutrients["Protein"] = nutrient["value"].double!
            case "Total lipid (fat)": // fat in gram.
                nutrients["fat"] = nutrient["value"].double!
            case "Carbohydrate, by difference": // in gram.
                nutrients["Carbohydrate"] = nutrient["value"].double!
            case "Fiber, total dietary": // in gram.
                nutrients["fiber"] = nutrient["value"].double!
            case "Sugars, total": // grams.
                nutrients["sugar"] = nutrient["value"].double!
            case "Glucose (dextrose)":
                nutrients["glucose"] = nutrient["value"].double!
            default: break
            }
        }
        
    }
    
    var description: String {
        // Create nice readable form sorted labels for visual display.
        var desc = ""
        for (name, value) in nutrients {
            desc += "\(name): \(value)\n"
        }
        return desc
    }
    
}