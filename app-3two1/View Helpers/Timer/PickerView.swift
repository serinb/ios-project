//
//  PickerView.swift
//  app-3two1
//
//  Created by Chantal Rohde on 27.01.24.
//

import Foundation
import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR TASK AND PROJECT PICKER IN TIMER **/

struct PickerView: View {

    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    // provides required functions
    var dataModel = CoreDataModel()
    
    // parent view provides selectable projects
    @Binding var projectsToPick:[Project]
    
    // provide to parent view
    
    @Binding var selectedProject:String
    @Binding var selectedTask:String
    @Binding var isProjectSheetPresented:Bool

    // manage selectable tasks
    @State var tasks2Pick = [""]
    
    // toggles for project and task sheet
    @State var isTaskSheetPresented = false
    
    // update provided projects for picker
    func fetchTasksForPicker() {
        tasks2Pick = []

        for task in dataModel.getTasksForProject(project: selectedProject) {
            tasks2Pick.append(task.name!)
        }
    }
    
    // auto select last task if available
    func resetTaskSelection() {
        if(!tasks2Pick.isEmpty) {
           
            if let last = tasks2Pick.last {
                selectedTask =  last
            }
        }
        else {
            selectedTask = ""
        }
    }
    

    var body: some View {
        HStack { // PROJECT AND TASK PICKER VIEW

            VStack {
                if(projectsToPick.isEmpty) {
                    Text("CREATE A NEW PROJECT").font(Appearance().timerTextSmall)
                }
                else {
                    Text("PICK A PROJECT").font(Appearance().timerTextSmall)
                }
                Picker("Project Picker", selection: $selectedProject) {
                    ForEach(projectsToPick, id: \.self) { project in
                        if let projectName = project.name {
                            Text(projectName).tag(projectName)
                                .bold()
                        }
                    }

                    Image(systemName: "plus").tag("addProject")
                    
                }
                .padding(.top, -20)
                .onTapGesture { // if no projects are availabe, show project sheet on tap
                    if(dataModel.fetchSavedProjects().isEmpty){
                        isProjectSheetPresented.toggle()
                    }
                    print("SELECTED PROJECT:\(selectedProject) SELECTED TASK:\(selectedTask)")
                }
                .frame(height: 120)
                .cornerRadius(10)
                .pickerStyle(WheelPickerStyle())
            }
            .padding(.top, -60)

            VStack {
                if(!projectsToPick.isEmpty){  // show task picker only if projects are available
                    if(tasks2Pick.isEmpty) {
                        Text("CREATE A NEW TASK").font(Appearance().timerTextSmall)
                    }
                    else {
                        Text("PICK A TASK").font(Appearance().timerTextSmall)
                    }
                
                // task picker that provides available tasks
                Picker("Task Picker", selection: $selectedTask) {
                    
                    ForEach(tasks2Pick, id: \.self) { task in
                        Text(task).tag(task)
                    }
                    Image(systemName: "plus").tag("addTask")
                    
                }
                .padding(.top, -20)
                .frame(height: 120)
                .cornerRadius(10)
                .pickerStyle(WheelPickerStyle())
                .onChange(of:selectedProject){ // change selection of tasks with change of selected project
                    
                    tasks2Pick = []
                    for task in dataModel.getTasksForProject(project: selectedProject){
                        tasks2Pick.append(task.name!)
                    }
                    print("Project changed")
                    resetTaskSelection()
                }
                .onAppear{
                    fetchTasksForPicker()
                    resetTaskSelection()
                }
                .onTapGesture { // offer task sheet as only option if no tasks are available
                    if(tasks2Pick.isEmpty){
                    isTaskSheetPresented.toggle()

                    }
                }
            }
        }
            .padding(.top, -60)
        }
        
        // if the plus on the left is selected, trigger project sheet
        .onChange(of:selectedProject){
            
            if(!projectsToPick.isEmpty && selectedProject == "addProject"){
                isProjectSheetPresented.toggle()
            }
        }
        
        // if the plus on the right is selected, trigger task sheet
        .onChange(of:selectedTask) {
            if(!tasks2Pick.isEmpty && selectedTask == "addTask"){
                isTaskSheetPresented.toggle()
                print("SHOW TASK SHEET")
            }
        }
 
        // open task sheet then refresh and reset task picker
        .sheet(isPresented: $isTaskSheetPresented, onDismiss: {
            isTaskSheetPresented = false
            fetchTasksForPicker()
            resetTaskSelection()
        }) {
            if let project = dataModel.getProjectFromString(selectedProject) {
                AddTask2(taskSheetOpen: $isTaskSheetPresented, selection: project)
            }
        }
        
    }
         
}

#Preview {
    ContentView()
}

