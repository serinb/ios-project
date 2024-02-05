//
//  EditItems.swift
//  app-3two1
//
//  Created by Anubhav Punetha on 29.01.24.
//

import SwiftUI
import CoreData

struct EditItem: View {
    @Binding var editItemSheetOpen: Bool
    @Binding var savedProjects: [Project]
    @Binding var savedTasks: [Task]
    @Binding var givenItem: Item
    @State var givenProject: Project
    @State var givenTask: Task
    
    @State var startDesired: Date
    @State var endDesired: Date
    
    // Access to core data functions
    var dataModel = CoreDataModel()
    
    var body: some View {
        NavigationView {
            // Move the initialization here
            Form {
                // Picker for project
                Picker("Choose a project", selection: $givenProject) {
                    ForEach(savedProjects, id: \.self) { project in
                        Text(project.name ?? "")
                    }
                }
                .pickerStyle(.menu)
                //picker for task
                Picker("Choose a task:", selection: $givenTask) {
                    ForEach(savedTasks.filter { $0.originProject == givenItem.taskForTimestamp?.originProject }) { task in
                        Text(task.name ?? "")
                    }
                }
                .pickerStyle(.menu)
                //picker for start
                DatePicker("Start:", selection: $startDesired, displayedComponents: [.date, .hourAndMinute])
                //picker for end
                DatePicker("End:", selection: $endDesired, displayedComponents: [.date, .hourAndMinute])
                
            }
            .navigationTitle("Edit Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        //Save button
                        saveItemEdit()
                        editItemSheetOpen.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", action: {
                        editItemSheetOpen.toggle()
                    })
                }
            }.onChange(of: startDesired){
                if startDesired < Date.now{
                    startDesired = Date.now
                }else{
                    endDesired = startDesired.addingTimeInterval(1500)
                }
            }
            .onChange(of: endDesired){
                if endDesired <= startDesired{
                    endDesired = startDesired.addingTimeInterval(1500)
                } else if endDesired > startDesired.addingTimeInterval(7200){
                    endDesired = startDesired.addingTimeInterval(7200)
                } else {
                    
                }

            }
            
        }
        
    }
    private func saveItemEdit() {
        let context = PersistenceController.shared.container.viewContext
        givenItem.taskForTimestamp = givenTask
        givenItem.taskForTimestamp!.originProject = givenProject
        givenItem.timestamp = startDesired
        givenItem.timestampEnd = endDesired
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
}
