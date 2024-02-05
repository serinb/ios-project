//
//  EditItems.swift
//  app-3two1
//
//  Created by Anubhav Punetha on 29.01.24.
//

import SwiftUI
import CoreData


struct EditItem: View {
    @Binding var itemSheetOpen: Bool
    @State private var closeAlert = false
    @Binding var savedProjects: [Project]
    @Binding var savedTasks: [Task]
    @State var selectedProject: Project
    @State var selectedTask: Task
    
    @State var startDesired = Date.now
    @State var endDesired = Date.now.addingTimeInterval(1500)
    
    //access to core data functions
    var dataModel = CoreDataModel()
    
    
    var body: some View {
        NavigationView{
            Form{
                Picker("Choose a project", selection: $selectedProject) {
                    ForEach(savedProjects, id: \.self) {
                        Text($0.name!)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Choose a task:", selection: $selectedTask) {
                    ForEach(savedTasks, id: \.self) {
                        if $0.originProject == selectedProject {
                            Text($0.name!)
                        }
                    }
                }
                .pickerStyle(.menu)

                DatePicker("Start:", selection: $startDesired, displayedComponents: [.date, .hourAndMinute])
                
                DatePicker("End:", selection: $endDesired, displayedComponents: [.date, .hourAndMinute])
                
                
                .navigationTitle("Add Event")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            dataModel.saveItemToCoreData(forProject: selectedProject, forTask: selectedTask, startTime: startDesired, endTime: endDesired)
                            itemSheetOpen.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close", systemImage: "xmark") {
                            itemSheetOpen.toggle()
                        }
                    }
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
}


//#Preview {
//    AddItem()
//}
