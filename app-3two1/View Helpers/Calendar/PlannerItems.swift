//
//  PlannerItems.swift
//  app-3two1
//
//  Created by Serin on 28.01.24.
//

import SwiftUI

/** CONTAINS THE STRUCTURE OF TASK ITEM BOX, SIMILAR TO TASKVIEW **/

struct PlannerItems: View {
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    @Binding var savedProjects: [Project]
    @Binding var filteredTasks: [Task]
    @State var givenItem: Item
    @Binding var filteredItems: [Item]
    
    @State public var editItemSheetOpen = false
    
    //access to core data functions
    var dataModel = CoreDataModel()
    
    var body: some View {
        VStack { // Two layers: 1. Picture, Title, Tags; 2. Date, timespent
            HStack {
                VStack {
                    HStack {
                        VStack {
                            // Task name
                            if let taskName = givenItem.taskForTimestamp?.name {
                                Text(taskName)
                                    .font(Appearance().taskViewTaskName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                // Handle the case where taskName is nil
                                Text("Unknown Task")
                                    .font(Appearance().taskViewTaskName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Project name
                            if let projectName = givenItem.taskForTimestamp?.originProject?.name {
                                Text(projectName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(Appearance().taskViewProjectName)
                            } else {
                                // Handle the case where projectName is nil
                                Text("Unknown Project")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(Appearance().taskViewProjectName)
                            }
                        }
                        //Task Edit Button here
                        Button {
                            editItemSheetOpen.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(-90))
                                .foregroundStyle(colorThemeSelection.colorAccentPick)
                                .padding([.top, .trailing], -10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $editItemSheetOpen, onDismiss: self.fetchSavedItems, content: {
                            EditItem(editItemSheetOpen: $editItemSheetOpen, savedProjects: $savedProjects, savedTasks: $filteredTasks, givenItem: $givenItem, givenProject: givenItem.taskForTimestamp!.originProject!, givenTask: givenItem.taskForTimestamp!, startDesired: givenItem.timestamp!, endDesired: givenItem.timestampEnd!)
//                            EditItem2(givenItem: $givenItem.taskForTimestamp)
                            .presentationDetents([.fraction(0.4), .medium])
                            .presentationDragIndicator(.visible)
                            
                        })
                    }
                    //Time and duration of a task here
                    HStack {
                        Text("Time: \(givenItem.timestamp!...givenItem.timestampEnd!)")
                            .font(Appearance().sectionTitle)
                        Spacer()
                        Text("Duration: \(calculateDuration()) min").font(Appearance().sectionTitle)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                }
            }
        }
    }
    
    func calculateDuration() -> Int {
        let calendar = Calendar.current
        
        if let difference = calendar.dateComponents([.minute], from: givenItem.timestamp!, to: givenItem.timestampEnd!).minute {
            return difference
        } else {
            // Return a default value if subtraction fails (you can handle this case based on your requirements)
            return 0
        }
    }
    func fetchSavedItems() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            filteredItems = try context.fetch(Item.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
