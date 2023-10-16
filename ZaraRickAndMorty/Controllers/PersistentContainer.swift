//
//  PersistentContainer.swift
//  ZaraRickAndMorty
//
//  Created by Marc on 15/10/2023.
//

import Foundation
import UIKit
import CoreData

class PersistentContainer {
    
    // MARK: - Get AppData
    static func getAppData(completionHandler: @escaping (Int?, Bool?, Set<Int>?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        
        var currentPage: Int?
        var showBookmarkedCharactersOnly: Bool?
        var bookmarkedCharactersIDs: Set<Int>?
        
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "AppData")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                if let result: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject] {
                    
                    for managedObject in result {
                        
                        if let dataValue = managedObject.value(forKey: "currentPage") as? Int {
                            
                            currentPage = dataValue
                        }
                        
                        if let dataValue = managedObject.value(forKey: "showBookmarkedCharactersOnly") as? Bool {
                            
                            showBookmarkedCharactersOnly = dataValue
                        }
                        
                        if let dataValue = managedObject.value(forKey: "bookmarkedCharactersIDs") as? Set<Int> {
                            
                            bookmarkedCharactersIDs = dataValue
                        }
                    }
                } else {
                    
                    errorHandler(NSError(domain: "", code: 453, userInfo: [NSLocalizedDescriptionKey : "Error while fetching Core Data request"]))
                }
            } catch {
                
                errorHandler(NSError(domain: "", code: 453, userInfo: [NSLocalizedDescriptionKey : "Error while fetching Core Data request"]))
            }
        } else {
            
            errorHandler(NSError(domain: "", code: 453, userInfo: [NSLocalizedDescriptionKey : "Error while fetching Core Data request"]))
        }
        
        completionHandler(currentPage, showBookmarkedCharactersOnly, bookmarkedCharactersIDs)
    }

    // MARK: - Save AppData
    static func saveAppData(value: Any?, key: String, errorHandler: @escaping (Error?) -> Void) {
        
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "AppData")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                if let result: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject], result.count > 0 {
                    
                    for managedObject in result {
                        
                        managedObject.setValue(value, forKey: key)
                    }
                } else if let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "AppData", in: context) {
                    
                    let managedObject: NSManagedObject = NSManagedObject(entity: entity, insertInto: context)
                    
                    managedObject.setValue(value, forKey: key)
                } else {
                    
                    errorHandler(NSError(domain: "", code: 453, userInfo: [NSLocalizedDescriptionKey : "Error while fetching Core Data request"]))
                }
                
                try context.save()
            } catch {
                
                errorHandler(NSError(domain: "", code: 453, userInfo: [NSLocalizedDescriptionKey : "Error while fetching Core Data request"]))
            }
        } else {
            
            errorHandler(NSError(domain: "", code: 453, userInfo: [NSLocalizedDescriptionKey : "Error while fetching Core Data request"]))
        }
    }
}
