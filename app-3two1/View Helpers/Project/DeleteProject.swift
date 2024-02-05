//
//  DeleteProject.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 22.01.24.
//

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR DELETE PROJECT SHEET **/

struct DeleteProject: View {
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    @Binding var isSettingsAlertPresented: Bool
    @State private var projectDeleteAlert: Bool = false
    @State private var willContinue: Bool = false
    @Binding var savedProjects: [Project]
    @Binding var savedTasks: [Task]
    //@State private var closeAlert = false
    
    //to address current font size

    @State var selection: Project
    
    var body: some View {
        NavigationView{
            Form {
                
                Section {
                    Picker(selection: $selection,  label: Text("Choose a project to delete:").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {
                            Text($0.name!)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.projectDeleteAlert.toggle()
                        } label: {
                            Text("Delete")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Delete Project").bold().font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isSettingsAlertPresented.toggle()
                        } label: {
                            Text("Close").foregroundStyle(colorThemeSelection.colorAccentPick).font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                .alert("All tasks in this project will be deleted. Do you want to continue?", isPresented: $projectDeleteAlert) {
                    Button("Yes") {
                        self.willContinue = true
                        self.projectDeleteAlert = false
                        self.deleteSavedProject(project: selection)
                        self.fetchSavedProjects()
                        self.fetchSavedTasks()
                        self.isSettingsAlertPresented = false
                    }
                    Button("No") {
                        self.willContinue = false
                        self.projectDeleteAlert = false
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.standardTheme)
            .environment(\.colorScheme, displayTheme.themePick!)
        }
    }
    
    private func deleteSavedProject(project: Project) {
        let context = PersistenceController.shared.container.viewContext
        // Delete item from Core Data model
        context.delete(project)
        
        // Save context after deletion
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
        //self.fetchSavedProjects()
    }
    
    private func fetchSavedProjects() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            self.savedProjects = try context.fetch(Project.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
    private func fetchSavedTasks() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            self.savedTasks = try context.fetch(Task.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
}

#Preview {
    TaskListView()
}
