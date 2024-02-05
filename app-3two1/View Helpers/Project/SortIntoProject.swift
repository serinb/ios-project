//
//  SortIntoProject.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 24.01.24.
//

import SwiftUI

/** CONTAINS THE STRUCTURE FOR "MOVE TASK TO PROJECT" SHEET **/

struct SortIntoProject: View {
    
    //Bool for sheet
    @Binding var folderChosen: Bool
    
    //Parameters for calling the View
    @Binding var savedProjects: [Project]
    var selectedTasks: Set<Task>
    @State var selection: Project
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    
    
    var body: some View {
        NavigationView{
            if savedProjects != []
            {
                Form {
                    //Select project
                    Picker(selection: $selection, label: Text("Select new project destination").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {
                            Text($0.name!)
                        }
                        
                    }
                    .pickerStyle(.menu)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                // Save to Core Data
                                self.moveTasks()
                                folderChosen.toggle()
                            } label: {
                            Text("Save")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Move To New Project").bold().font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            //Close sheet
                            folderChosen.toggle()
                        } label: {
                            Text("Close").foregroundStyle(colorThemeSelection.colorAccentPick).font(fontSizeSelection.fontSizePick)
                        }
                    }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.standardTheme)
                .environment(\.colorScheme, displayTheme.themePick!)
            }
        }
    }
    
    //Moves task from one project to another in Core Data
    private func moveTasks() {
        let context = PersistenceController.shared.container.viewContext
        // Delete item from Core Data model
        print(selectedTasks)
        for task in selectedTasks {
            task.originProject = selection
        }
        
        // Save context after deletion
        do {
            try context.save()
            print("Saved")
        } catch {
            print("Error saving after moving: \(error)")
        }
        //self.fetchSavedProjects()
    }
}

#Preview {
    TaskListView()
}
