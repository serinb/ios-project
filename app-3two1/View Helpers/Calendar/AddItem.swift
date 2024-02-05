//
//  AddItem.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 26.01.24.
//

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR ADD SCHEDULED TASK SHEET **/

struct AddItem: View {
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
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var body: some View {
        NavigationView{
            Form{
                Section {
                    //Picker for project
                    Picker(selection: $selectedProject, label: Text("Choose a project").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {
                            Text($0.name!).font(fontSizeSelection.fontSizePick)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    //picker for tasks
                    Picker(selection: $selectedTask , label: Text("Choose a task:").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedTasks, id: \.self) {
                            if $0.originProject == selectedProject {
                                Text($0.name!).font(fontSizeSelection.fontSizePick)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    //Picker for start date
                    DatePicker("Start:", selection: $startDesired, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    //picker for end date
                    DatePicker("End:", selection: $endDesired, displayedComponents: [.date, .hourAndMinute])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            //Save Button
                            dataModel.saveItemToCoreData(forProject: selectedProject, forTask: selectedTask, startTime: startDesired, endTime: endDesired)
                            itemSheetOpen.toggle()
                        } label: {
                            Text("Save")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Schedule a Task").bold().font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            itemSheetOpen.toggle()
                        } label: {
                            Text("Close").foregroundStyle(colorThemeSelection.colorAccentPick).font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.standardTheme)
            .environment(\.colorScheme, displayTheme.themePick!)
            
            .onChange(of: startDesired){
                // parameters for start
                if startDesired < Date.now{
                    startDesired = Date.now
                }else{
                    endDesired = startDesired.addingTimeInterval(1500)
                }
            }
            .onChange(of: endDesired){
            // parameters for end
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


#Preview {
   ContentView()
}
