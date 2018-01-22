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
        case employeeLastActivityDate
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
    
    public func employeeLastActivityDate() -> Date {
        
        // "22.01.2018:00:00"
        
        var dateString = "2018-01-22T18:07:00.660+0530"
        
        if let datStr = string(forKey: userDefaultsKeys.employeeLastActivityDate.rawValue) {
            dateString = datStr
                }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let date = dateFormatter.date(from: dateString)
        
        return date!
    }
    
    func setEmployeeLastActivityDate(_ date: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let dateString = dateFormatter.string(from: date)
        set(dateString, forKey: userDefaultsKeys.employeeLastActivityDate.rawValue)
        synchronize()
    }
}
