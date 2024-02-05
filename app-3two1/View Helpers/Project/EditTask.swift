//
//  DetailedTaskView.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 22.01.24.
//

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR EDIT TASK SHEET **/

struct EditTask: View {
    
    //Bool for sheet
    @Binding var editTaskSheetOpen: Bool
    
    //task to be edited
    @Binding var taskToEdit: Task?
    
    //User textfield input
    @State private var taskName = ""
    @State private var tagName = ""
    
    //Core Data
    @Binding var savedProjects: [Project]
    @Binding var savedTags: [Tag]
    @Binding var refreshID: UUID
    @State private var selection: Project? = nil
    @State private var selectedTags: [Tag] = []
    @State private var selectedIcon = "studentdesk"
    
    //Icon options
    @State private var Icons = ["studentdesk","graduationcap.fill","moon.stars.fill","figure.run","frying.pan.fill","book.pages.fill"]
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //Allows the user to edit existing tasks
    var body: some View {
        NavigationView{
            Form {
                // Icon selection
                Section(header: Text("Pick an icon")
                    .font(Appearance().sectionTitle)
                    .foregroundColor(colorThemeSelection.colorAccentPick)) {
                        
                    Picker("", selection: $selectedIcon) {
                        ForEach(Icons, id: \.self) {icon in
                            Image(systemName: icon)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                //Edit task name
                Section {
                    TextField("Enter new task name", text: $taskName)
                        .font(fontSizeSelection.fontSizePick)
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 15))
                        .background(.standardTheme)
                }
                //Edit project selection
                Section {
                    Picker(selection: $selection, label: Text("Assign to a project").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {project in
                            Text(project.name!)
                                .tag(project as Project?)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                //Tag selection
                Section {
                    NavigationLink {
                        MultipleTags(savedTags: $savedTags, selectedTags: $selectedTags)
                    } label: {
                        Text("Add Tags")
                    }
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.saveTaskEdit()
                            self.refreshID = UUID()
                            editTaskSheetOpen.toggle()
                        } label: {
                            Text("Save")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text(taskToEdit!.name!).bold().font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            editTaskSheetOpen.toggle()
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
        }
        .onAppear{
            fillData()
        }
    }
    

    private func fillData() {
        taskName = taskToEdit!.name!
        selection = taskToEdit!.originProject!
        selectedIcon = taskToEdit!.picture!
        selectedTags = taskToEdit!.assignedTags!.array as! [Tag]
    }
    
    private func saveTaskEdit() {
        let context = PersistenceController.shared.container.viewContext
        taskToEdit!.name = taskName // Save the provided name
        taskToEdit!.originProject = selection
        taskToEdit!.picture = selectedIcon
        taskToEdit!.assignedTags = NSOrderedSet(array: selectedTags as [Tag])
//        taskToEdit.taskCompleted = false
//        if selectedTags[0] != nil {
//            newTask.assignedTags = NSOrderedSet.init(array: [selectedTags[0]!])
//        }
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    private func saveTaskToCoreData() {
        let context = PersistenceController.shared.container.viewContext
        let newTask = Task(context: context)
        newTask.name = taskName // Save the provided name
        newTask.originProject = selection
        newTask.picture = selectedIcon
        newTask.taskCompleted = false
        newTask.assignedTags = NSOrderedSet.init(array: selectedTags)
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
    private func saveTagToCoreData() {
        let context = PersistenceController.shared.container.viewContext
        let newTag = Tag(context: context)
        newTag.name = tagName // Save the provided name
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
}

#Preview {
    TaskListView()
}
