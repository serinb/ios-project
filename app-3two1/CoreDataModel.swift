//
//  CoreDataModel.swift
//  app-3two1
//
//  Created by Chantal Rohde on 25.01.24.
//

import Foundation
import CoreData
import SwiftUI


// CLASS THAT PROVIDES ALL CORE DATA FUNCTIONS

class CoreDataModel {

// MANIPULATE PROJECT ENTITIES
    
    // returns an array of projects from core data
    func fetchSavedProjects() -> [Project] {
        var savedProjects=[Project]()
        let context = PersistenceController.shared.container.viewContext
        
        do {
            savedProjects = try context.fetch(Project.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        return savedProjects
    }
    
    // create a new project in core data
    func saveProjectToCoreData(name: String) {
        let context = PersistenceController.shared.container.viewContext
        
        let newProject = Project(context: context)
        newProject.name = name

        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    // delete a project from core data
    func deleteSavedProject(_ projectToDelete: Project) {
        let context = PersistenceController.shared.container.viewContext

        context.delete(projectToDelete)
        
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
    
    // get the corresponding project object from a string
    func getProjectFromString(_ projectName: String) -> Project? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@","\(projectName)")

        do {
            let project = try context.fetch(fetchRequest)

            if let project = project.first {
               // print("FOUND PROJECT")
                return project
            }
        } catch {
            print("Error fetching or saving: \(error)")
        }
        return nil
    }

    
// MANIPULATE TASK ENTITIES
    func fetchSavedTasks() -> [Task] {
        let context = PersistenceController.shared.container.viewContext
        var savedTasks=[Task]()
        do {
            // Fetch items from Core Data
            savedTasks = try context.fetch(Task.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        return savedTasks
    }
    
    func saveTaskToCoreData(taskName:String, forProject:Project, icon:String, tags:[Tag?] ) {
        let context = PersistenceController.shared.container.viewContext
        let newTask = Task(context: context)
        newTask.name = taskName // Save the provided name
        newTask.originProject = forProject
        newTask.picture = icon
        newTask.taskCompleted = false
        if tags[0] != nil {
            newTask.assignedTags = NSOrderedSet.init(array: [tags[0]!])
        }
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    // delete a task from core data
    func deleteSavedProject(_ taskToDelete: Task) {
        let context = PersistenceController.shared.container.viewContext

        context.delete(taskToDelete)
        
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
    
    // delete several tasks from core data
    func deleteSavedTasks(in savedTasks:[Task], at offsets: IndexSet) {
        let context = PersistenceController.shared.container.viewContext
        // Delete item from Core Data model
        for index in offsets {
            let taskToDelete = savedTasks[index]
            context.delete(taskToDelete)
        }

        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
    
    
    func getTaskFromString(_ taskName:String) -> Task? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@","\(taskName)")

        do {
            let task = try context.fetch(fetchRequest)

            if let task = task.first {
               // print("FOUND TASK")
                return task
            }
        } catch {
            print("Error fetching or saving: \(error)")
        }
        print("COULNT FIND \(taskName)")
        return nil
    }
    
    func getTasksForProject(project:String)-> [Task] {
        var availableTasks: [Task] = []

        if let project = getProjectFromString(project) {
              if let tasks = project.assignedTasks {
                  for task in tasks {
                      if let taskObject = task as? Task {
                          availableTasks.append(taskObject)
                      }
                  }
              }
          }
        return availableTasks
    }

// MANIPULATE TAG ENTITIES
    func fetchSavedTags() -> [Tag] {
        let context = PersistenceController.shared.container.viewContext
        var savedTags=[Tag]()
        do {
            // Fetch items from Core Data
            savedTags = try context.fetch(Tag.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        return savedTags
    }
    
    func saveTagToCoreData(_ name: String) {
        let context = PersistenceController.shared.container.viewContext
        let newTag = Tag(context: context)
        newTag.name = name // Save the provided name
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
// MANIPULATE ITEM ENTITIES
    
    // get an array of all the items stored
    func fetchSavedItems() -> [Item] {
        var savedItems=[Item]()
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            savedItems = try context.fetch(Item.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        return savedItems
    }
    
    // save an item to core data (FETCH AFTER ADDING!)
    func saveItemToCoreData(forProject:Project, forTask:Task, startTime:Date?, endTime:Date?) {
         let context = PersistenceController.shared.container.viewContext

         let newItem = Item(context: context)
         newItem.timestamp = startTime
         newItem.timestampEnd = endTime
         newItem.taskForTimestamp = forTask
         newItem.taskForTimestamp!.originProject = forProject
        
         do {
             try context.save()
         } catch {
             print("Error saving to Core Data: \(error)")
         }
     }
    
    // delete an item from core data (FETCH AFTER DELETE!)
    func deleteSavedItem(_ itemToDelete:Item) {
        // get context
        let context = PersistenceController.shared.container.viewContext
        
        // delete item
        context.delete(itemToDelete)
        
        // Save context after deletion
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
    
    func deleteSavedItems(in savedItems:[Item], at offsets: IndexSet) {
        let context = PersistenceController.shared.container.viewContext
        for index in offsets {
            let itemToDelete = savedItems[index]
            context.delete(itemToDelete)
        }
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
    
// MANIPULATE PROGRESS ENTITIES
    func fetchSavedProgress() -> Progress? {
        let context = PersistenceController.shared.container.viewContext
        var savedProgress=[Progress]()
        do {
            // Fetch items from Core Data
            savedProgress = try context.fetch(Progress.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        if let first = savedProgress.first {
            return first
        }
        else {
            return nil
        }
        print("PROGRESS FETCHED")
    }
    
    func getGoal() -> Int {
        let context = PersistenceController.shared.container.viewContext
        var savedProgress=[Progress]()
        do {
            // Fetch items from Core Data
            savedProgress = try context.fetch(Progress.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        if let first = savedProgress.first {
            return Int(first.trackingGoal)
        }
        else {
            return 0
        }
        print("PROGRESS FETCHED")
    }
    
    func getTracks() -> Int {
        let context = PersistenceController.shared.container.viewContext
        var savedProgress=[Progress]()
        do {
            // Fetch items from Core Data
            savedProgress = try context.fetch(Progress.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
        if let first = savedProgress.first {
            return Int(first.trackedTimes)
        }
        else {
            return 0
        }
        print("PROGRESS FETCHED")
    }

    
    func saveProgressToCoreData(goal:Int, tracks:Int) {
        clearAllProgress()
        let context = PersistenceController.shared.container.viewContext
        let newProgress = Progress(context: context)
        newProgress.trackingGoal = Int16(goal)
        newProgress.trackedTimes = Int16(tracks)
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
        print("PROGRESS SAVED")
    }

    func clearAllProgress() {
            let context = PersistenceController.shared.container.viewContext

            // Create a fetch request for your entity
            let fetchRequestForProgress: NSFetchRequest<NSFetchRequestResult> = Progress.fetchRequest()

            // Create a batch delete request
            let batchDeleteRequestForProgress = NSBatchDeleteRequest(fetchRequest: fetchRequestForProgress)

            do {
                // Perform the batch delete
                try context.execute(batchDeleteRequestForProgress)
                print("PROGRESS CLEARED")
                
                // Save the context to persist the changes
                try context.save()
            } catch {
                // Handle the error
                print("Error deleting data: \(error)")
            }
    }
    
    
  

// MANIPULATE ALL ENTITIES
    
    func fetchSavedEntities()-> ([Project],[Task],[Item],[Tag]) {
            let context = PersistenceController.shared.container.viewContext
            
            var savedProjects = [Project]()
            var savedTasks = [Task]()
            var savedItems = [Item]()
            var savedTags = [Tag]()
        
            do {
                // Fetch items from Core Data
                savedProjects = try context.fetch(Project.fetchRequest())
                savedItems = try context.fetch(Item.fetchRequest())
                savedTasks = try context.fetch(Task.fetchRequest())
                savedTags = try context.fetch(Tag.fetchRequest())
            } catch {
                print("Error fetching from Core Data: \(error)")
            }
            return (savedProjects,savedTasks,savedItems, savedTags)
    }
    
    func clearAllEntityData() {
            let context = PersistenceController.shared.container.viewContext

            // Create a fetch request for your entity
            let fetchRequestForProject: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
            let fetchRequestForItem: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
            let fetchRequestForTask: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
            

            // Optionally, you can add a predicate to filter the data you want to delete
            // let predicate = NSPredicate(format: "yourAttribute == %@", yourValue)
            // fetchRequest.predicate = predicate

            // Create a batch delete request
            let batchDeleteRequestForProject = NSBatchDeleteRequest(fetchRequest: fetchRequestForProject)
            let batchDeleteRequestForItem = NSBatchDeleteRequest(fetchRequest: fetchRequestForItem)
            let batchDeleteRequestForTask = NSBatchDeleteRequest(fetchRequest: fetchRequestForTask)

            do {
                // Perform the batch delete
                try context.execute(batchDeleteRequestForTask)
                print("TASKS DELETED")
                // Save the context to persist the changes
                try context.save()
                print("CONTEXT SAVED")
            } catch {
                // Handle the error
                print("Error deleting data: \(error)")
            }
        do {
            // Perform the batch delete
            try context.execute(batchDeleteRequestForProject)

            // Save the context to persist the changes
            try context.save()
        } catch {
            // Handle the error
            print("Error deleting data: \(error)")
        }
        do {
            // Perform the batch delete
            try context.execute(batchDeleteRequestForItem)

            // Save the context to persist the changes
            try context.save()
        } catch {
            // Handle the error
            print("Error deleting data: \(error)")
        }
        print("ENTITIES FETCHED")
    }

  

}


class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = persistentContainer.viewContext
        return true
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "app_3two1")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
