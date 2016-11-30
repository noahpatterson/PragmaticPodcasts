//
//  CoreDataStack.swift
//  PragmaticPodcasts
//
//  Created by Noah Patterson on 11/30/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import CoreData
class CoreDataStack {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FeedModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    } 
}
