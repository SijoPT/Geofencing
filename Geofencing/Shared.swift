//
//  SharedFile.swift
//  Geofencing
//
//  Created by Sijo on 03/01/18.
//  Copyright © 2018 Sijo. All rights reserved.
//

import UIKit

public let storyborad = UIStoryboard(name: "Main", bundle: nil)
public let mapContlrStrBrdId = "MapViewController"
public let userContlrStrBrdId = "UserIdentifcationController"

struct Section {
    
    var empIDs: [String]
    var area: [String]
    var selected: String
    
    public init(empIDs: [String], area: [String], selected: String) {
        
        self.empIDs   = empIDs
        self.area   = area
        self.selected = selected
    }
}

struct Area {
    
    var department: String?
    var floor: String?
    
    public init(department: String, floor: String) {
        
        self.department = department
        self.floor = floor
    }
}

public func returnViewController(_ identifier: String) -> UIViewController {
    
    return UIViewController()
}
