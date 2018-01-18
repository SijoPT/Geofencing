//
//  CoreDataHandler.swift
//  Geofencing
//
//  Created by Sijo on 03/01/18.
//  Copyright © 2018 Sijo. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler: NSObject {
    
    /*
     * This function is private class function
     * Which returns a persistentContainer context
    */
    
    private class func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    /*
     * Save entity attributte value to container
     */
    class func saveObject(empID: String, dept: String, floor: String) -> Bool {
        
        let context = getContext()
        let entinty = NSEntityDescription.entity(forEntityName: "Employee", in: context)
        let managedObject = NSManagedObject(entity: entinty!, insertInto: context)
        
        managedObject.setValue(empID, forKey: "empIDs")
        managedObject.setValue(dept, forKey: "depts")
        managedObject.setValue(floor, forKey: "floors")
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    /*
     * Save entity attributte value to container
     */
    class func saveObject(empID: String, longitude: Double, latitude: Double, altitude: Double, entered: NSDate, exited: NSDate) -> Bool {
        
        let context = getContext()
        let entinty = NSEntityDescription.entity(forEntityName: "Track", in: context)
        let managedObject = NSManagedObject(entity: entinty!, insertInto: context)
        
        managedObject.setValue(empID, forKey: "empID")
        managedObject.setValue(longitude, forKey: "longitude")
        managedObject.setValue(latitude, forKey: "latitude")
        managedObject.setValue(altitude, forKey: "altitude")
        managedObject.setValue(entered, forKey: "enter")
        managedObject.setValue(exited, forKey: "exit")
        
        do {
            try context.save()
            print("Context Saved..")
            return true
        } catch {
            return false
        }
    }
    
    /*
     * Fetch entity attributtes values from container
     */
    class func fetchObject() -> [Employee]? {
        
        let context = getContext()
        var employee:[Employee]? = nil
        do {
            employee = try context.fetch(Employee.fetchRequest())
            return employee
        } catch {
            return employee
        }
    }
    
    /*
     * Fetch entity attributtes values from container
     */
    class func fetchTrackObject() -> [Track]? {
        
        let context = getContext()
        var track:[Track]? = nil
        do {
            track = try context.fetch(Track.fetchRequest())
            return track
        } catch {
            return track
        }
    }

    
    /*
     * Delete entity attributte value from container
     */
    class func deleteObject(employee: Employee) -> Bool {
        
        let context = getContext()
        context.delete(employee)
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    /*
     * Clean all entity attributtes from container
     */
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Employee.fetchRequest())
        
        do {
            try context.execute(delete)
            return true
        } catch {
            return false
        }
    }
    
    /*
     * Which tell specified empID is valid
     */
    class func isValid(_ empID: String) -> [Employee]? {
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        var employee: [Employee]? = nil
        
        let predicate = NSPredicate(format: "empIDs contains[c] %@", empID)
        fetchRequest.predicate = predicate
        
        do {
            employee = try context.fetch(fetchRequest)
            return employee
        } catch {
            return employee
        }
    }
}
