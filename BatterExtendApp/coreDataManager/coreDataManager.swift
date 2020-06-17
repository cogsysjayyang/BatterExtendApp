//
//  coreDataManager.swift
//  BatterExtendApp
//
//  Created by xiaoke yang on 2020/06/04.
//  Copyright © 2020 xiaoke yang. All rights reserved.
//

import Cocoa
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let modelName: String = "AutoActionList"
    
    func getAutoActionList(ascending: Bool = false) -> [AutoActionList] {
        var models: [AutoActionList] = [AutoActionList]()
        
        if let context = context {
            let appNameSort: NSSortDescriptor = NSSortDescriptor(key: "appName", ascending: ascending)
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: modelName)
            fetchRequest.sortDescriptors = [appNameSort]
            
            do {
                if let fetchResult: [AutoActionList] = try context.fetch(fetchRequest) as? [AutoActionList] {
                    models = fetchResult
                }
            } catch let error as NSError {
                print("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        }
        return models
    }
    
    func saveAutoActionList(actionName: String,
                            appName: String, appIcon: Data, scriptPath: String, onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: modelName, in: context) {
            
            if let autoActionList: AutoActionList = NSManagedObject(entity: entity, insertInto: context) as? AutoActionList {
                autoActionList.actionName = actionName
                autoActionList.appName = appName
                autoActionList.appIcon = appIcon
                autoActionList.scriptPath = scriptPath
                
                contextSave { success in
                    onSuccess(success)
                }
            }
        }
    }
    
    func deleteAutoActionList(appName: String, subRow: Int, onSuccess: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(appName: appName)
        
        do {
            if let results: [AutoActionList] = try context?.fetch(fetchRequest) as? [AutoActionList] {
                if results.count != 0 {
                    context?.delete(results[subRow])
                }
            }
        } catch let error as NSError {
            print("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false)
        }
        
        contextSave { success in
            onSuccess(success)
        }
    }
}

extension CoreDataManager {
    fileprivate func filteredRequest(appName: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: modelName)
        fetchRequest.predicate = NSPredicate(format: "appName = %@", NSString(string: appName))
        return fetchRequest
    }
    
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
