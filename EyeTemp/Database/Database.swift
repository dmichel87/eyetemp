//
//  Database.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/18/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import Foundation
import CoreData

extension Date {
    
    func minutes(from date:Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date).minute ?? 0
    }
}

class Database {
    // MARK: - Core Data stack
    private init() {
        
    }
    
    static var context:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EyeTemp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static func isDeviceMonitored(deviceId:String, context:NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Appliances")
        fetchRequest.predicate = NSPredicate(format: "mapped_device_id = %@", deviceId)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                for object in records {
                    let obj = object as! Appliances
                    if obj.is_monitoring {
                        return true
                    }
                }
                
            }

        }
        catch {
            
        }
        return false

    }
    
    static func monitorDevice(objid:NSManagedObjectID, deviceId:String,flag:Bool, context:NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Appliances")
        fetchRequest.predicate = NSPredicate(format: "SELF = %@ && mapped_device_id = %@", objid, deviceId)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0] as! Appliances
                object.setValue(flag, forKey: "is_monitoring")
                try context.save()
            }
            
        }
        catch {
            
        }

    }
    
    static func updateContact(contact:Contacts,context:NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Contacts")
        fetchRequest.predicate = NSPredicate(format: "SELF = %@", contact.objectID)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0] as! Contacts
                object.setValue(contact.contact_name, forKey: "contact_name")
                object.setValue(contact.email, forKey: "email")
                object.setValue(contact.phone, forKey: "phone")
                try context.save()
            }

        }
        catch {
            Logger.log(message: "Unable to fetch managed objects for entity Contacts", event: .s)

        }


        
    }
    
    static func updateDevice(deviceId:String, deviceName:String, context:NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Devices")
        fetchRequest.predicate = NSPredicate(format: "device_id = %@", deviceId)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0] as! Devices
                object.setValue(deviceName, forKey: "device_name")
                try context.save()
            }
        }
        catch {
            Logger.log(message: "Unable to fetch managed objects for entity Devices", event: .s)
        }


    }
    static func deleteDevice(deviceId:String, context:NSManagedObjectContext )  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Devices")
        fetchRequest.predicate = NSPredicate(format: "device_id = %@", deviceId)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0]
                context.delete(object)
                try context.save()
            }
        }
        catch {
            Logger.log(message: "Unable to delete managed objects for entity Contacts", event: .s)
        }
    }
    
    static func deleteAppliance(name:String, context:NSManagedObjectContext )  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Appliances")
        fetchRequest.predicate = NSPredicate(format: "appliance_name = %@", name)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0]
                context.delete(object)
                try context.save()
            }
        }
        catch {
            Logger.log(message: "Unable to delete managed objects for entity Contacts", event: .s)
        }
    }
    
    static func canSaveAlert(text:String, context:NSManagedObjectContext) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EyeTempAlerts")
        fetchRequest.predicate = NSPredicate(format: "text = %@", text)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                if records.count == 0 {
                    return true
                }
                else if records.count > 0 {
                    if let object = records[0] as? EyeTempAlerts {
                        Logger.log(message: "Previously saved date \(object.alert_time!) with now \(Date())", event: .i)
                        if Date().minutes(from: object.alert_time!) > 15 {
                            return true
                        }
                    }
                }
                
            }
        }
        catch {
            Logger.log(message: "Unable to delete managed objects for entity Contacts", event: .s)
        }

        return false
    }
    
    static func deleteAlert(date:Date, context:NSManagedObjectContext )  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EyeTempAlerts")
        fetchRequest.predicate = NSPredicate(format: "alert_time = %@", date as NSDate)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0]
                context.delete(object)
                try context.save()
            }
        }
        catch {
            Logger.log(message: "Unable to delete managed objects for entity EyeTempAlerts", event: .s)
        }
    }
    
    static func deleteContact(emailId:String, context:NSManagedObjectContext )  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Contacts")
        fetchRequest.predicate = NSPredicate(format: "email = %@", emailId)
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                let object = records[0]
                context.delete(object)
                try context.save()
            }
        }
        catch {
            Logger.log(message: "Unable to delete managed objects for entity Contacts", event: .s)
        }
    }
    
    static func fetchRecordsForEntity(entity:String, context:NSManagedObjectContext) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:entity)
        var result = [NSManagedObject]()
        
        do {
            let records = try context.fetch(fetchRequest)
            if let records = records as? [NSManagedObject] {
                result = records
            }
        }
        catch {
            Logger.log(message: "Unable to fetch managed objects for entity \(entity)", event: .s)
        }
        return result
    }
    
    static func saveAlert(val:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(val, forKey: "ALERT_RECIEVED")
    }
    
    static func getAlert() -> Bool {
        return UserDefaults.standard.bool(forKey: "ALERT_RECIEVED")
    }
    
    static func addAlert(text:String, context:NSManagedObjectContext) {
        do {
            let alert = EyeTempAlerts(context:context)
            alert.alert_time = Date()
            alert.text = text
            try context.save()
        }
        catch {
            Logger.log(message: "Unable to save alert", event: .s)
        }
    }
    
    static func getAlertConfig() -> [Alert]? {
        do {
            let file = Bundle.main.path(forResource: "alerts", ofType: "json")
            let jsonData = try Data(contentsOf:  URL(fileURLWithPath:file!)) //try String(contentsOf: URL(fileURLWithPath:file!), encoding: String.Encoding.utf8)
            guard let alerts = [Alert].from(data: jsonData) else {
                return nil
            }
            return alerts
        }
        catch {
            
        }
        return nil
    }
    
    static func getLastAlert(context:NSManagedObjectContext) -> EyeTempAlerts? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"EyeTempAlerts")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"alert_time", ascending:false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let records = try context.fetch(fetchRequest)
            if records.count > 0 {
                return records[0] as? EyeTempAlerts
            }
            
        }
        catch {
            Logger.log(message: "Unable to fetch managed objects for entity EyeTempAlerts", event: .s)
        }
        return nil

    }
    
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                Logger.log(message: "Saved to database", event: .i)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
