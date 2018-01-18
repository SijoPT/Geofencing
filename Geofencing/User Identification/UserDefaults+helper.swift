//
//  UserDefaults+helper.swift
//  Geofencing
//
//  Created by Sijo on 04/01/18.
//  Copyright © 2018 Sijo. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum userDefaultsKeys: String {
        case isLoggedIn
        case employeeID
    }
    
    func setIsloggedIn(value: Bool) {
        set(value, forKey: userDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    public func isLoggedIn() -> Bool {
        return bool(forKey: userDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func setEmployeeID(value: String) {
        set(value, forKey: userDefaultsKeys.employeeID.rawValue)
        synchronize()
    }
    
    public func employeeID() -> String {
        return string(forKey: userDefaultsKeys.employeeID.rawValue)!
    }
}
