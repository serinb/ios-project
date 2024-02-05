//
//  AddTaskView.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 22.01.24.
//

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR ADD TASK SHEET **/

struct AddTask: View {
    
    var dataModel = CoreDataModel()
    
    @Binding var taskSheetOpen: Bool
    @State private var showSuggestions = false
    @State private var taskName = ""
    @State private var tagName = ""
    @State private var closeAlert = false
    @Binding var savedProjects: [Project]
    @Binding var savedTasks: [Task] 
    @Binding var savedTags: [Tag]
    @State var selection: Project
    @State private var selectedTags: [Tag] = []
    @State private var filteredTasksTemp: [String] = []
    @State private var selectedSuitableFor: [String] = []
    @State private var selectedIcon = "studentdesk"
    @State private var Icons = ["studentdesk","graduationcap.fill","moon.stars.fill","figure.run","frying.pan.fill","book.pages.fill"]
    
    @State private var attempts: Int = 0    // counter for the shake animation
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    @State private var hapticError = false
    
    var body: some View {
        NavigationView{
            Form{
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
                
                Section {
                    TextField("Enter task name", text: $taskName)
                        .onChange(of: taskName, { oldValue, newValue in
                            showSuggestions = true
                        })
                        .font(fontSizeSelection.fontSizePick)
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 15))
                        .background(.standardTheme)
                        .modifier(Shake(animatableData: CGFloat(attempts))) // shake animation modifier
     
                    if showSuggestions && !taskName.isEmpty {
                        ScrollView {
                            LazyVStack(alignment:.leading) {
                                ForEach(savedTasks.filter({ $0.name!.localizedCaseInsensitiveContains(taskName) }), id: \.self) { suggestion in
                                    ZStack {
                                        Button(action: {
                                            if (!selectedSuitableFor.contains(suggestion.name!)){
                                                selectedSuitableFor.append(suggestion.name!)
                                            }
                                            
                                            taskName = suggestion.name!
                                            selectedIcon = suggestion.picture!
                                            //selection = suggestion.originProject!
                                            //selectedTags[0] = suggestion.assignedTags
                                            showSuggestions = false
                                            
                                        })
                                        {
                                            VStack{
                                                Text(suggestion.name!)
                                                    .font(Appearance().taskViewTaskName)
                                                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 5))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(colorThemeSelection.colorAccentPick)
                                                Text(suggestion.originProject!.name!)
                                                    .font(Appearance().taskViewProjectName)
                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 5))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(colorThemeSelection.colorAccentPick)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                
                Section {
                    Picker(selection: $selection, label: Text("Assign to a project").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {
                            Text($0.name!)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                
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
                            if (taskName != "" && !selection.assignedTasks!.contains(dataModel.getTaskFromString(taskName) as Any)) {
                                // Save to Core Data
                                self.saveTaskToCoreData()
                                taskSheetOpen.toggle()
                            } else {
                                hapticError = true
                                // trigger the shake animation
                                withAnimation(.default) {
                                    attempts += 1
                                }
                            }
                        } label: {
                            Text("Save")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .sensoryFeedback(.error, trigger: hapticError) // haptic feedback
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Add Task").font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            taskSheetOpen.toggle()
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
    }
    
//    var filteredTasks: [String] {
//        for task in savedTasks {
//            if (!filteredTasksTemp.contains(task.name!)){
//                filteredTasksTemp.append(task.name!)
//            }
//        }
//        return filteredTasksTemp
//    }
    
    private func saveTaskToCoreData() {
        let context = PersistenceController.shared.container.viewContext
        let newTask = Task(context: context)
        newTask.name = taskName // Save the provided name
        newTask.originProject = selection
        newTask.picture = selectedIcon
        newTask.taskCompleted = false
        newTask.assignedTags = NSOrderedSet.init(array: selectedTags)
//        if selectedTags[0] != nil {
//            newTask.assignedTags = NSOrderedSet.init(array: [selectedTags[0]!])
//        }
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

struct AddTask2: View {
    
    var dataModel = CoreDataModel()
    
    @Binding var taskSheetOpen: Bool
    @State private var showSuggestions = false
    @State private var taskName = ""
    @State private var tagName = ""
    @State private var closeAlert = false

    @State var selection: Project
    @State private var selectedTags: [Tag] = []
    @State private var savedTags: [Tag] = []
    @State private var selectedSuitableFor: [String] = []
    @State private var selectedIcon = "studentdesk"
    @State private var Icons = ["studentdesk","graduationcap.fill","moon.stars.fill","figure.run","frying.pan.fill","book.pages.fill"]
    
    @State private var attempts: Int = 0    // counter for the shake animation
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    @State private var hapticError = false
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Pick an icon")
                    .font(Appearance().sectionTitle)
                    .foregroundColor(colorThemeSelection.colorAccentPick)){
                        
                    Picker("", selection: $selectedIcon) {
                        ForEach(Icons, id: \.self) {icon in
                            Image(systemName: icon)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    TextField("Enter task name", text: $taskName)
                        .onChange(of: taskName, { oldValue, newValue in
                            showSuggestions = true
                        })
                        .font(fontSizeSelection.fontSizePick)
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 15))
                        .background(.standardTheme)
                        .modifier(Shake(animatableData: CGFloat(attempts))) // shake animation modifier
     
                    if showSuggestions && !taskName.isEmpty {
                        ScrollView {
                            LazyVStack(alignment:.leading) {
                                ForEach(dataModel.fetchSavedTasks().filter({ $0.name!.localizedCaseInsensitiveContains(taskName) }), id: \.self) { suggestion in
                                    ZStack {
                                        Button(action: {
                                            if (!selectedSuitableFor.contains(suggestion.name!)){
                                                selectedSuitableFor.append(suggestion.name!)
                                            }
                                            
                                            taskName = suggestion.name!
                                            selectedIcon = suggestion.picture!
                                            selection = suggestion.originProject!
                                            //selectedTags[0] = suggestion.assignedTags
                                            showSuggestions = false
                                            
                                        })
                                        {
                                            VStack{
                                                Text(suggestion.name!)
                                                    .font(Appearance().taskViewTaskName)
                                                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 5))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(colorThemeSelection.colorAccentPick)
                                                Text(suggestion.originProject!.name!)
                                                    .font(Appearance().taskViewProjectName)
                                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 5))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(colorThemeSelection.colorAccentPick)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
                
                
                Section {
                    Picker("Assign to a project", selection: $selection) {
                        ForEach(dataModel.fetchSavedProjects(), id: \.self) {
                            Text($0.name!)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                
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
                            if (taskName != "" && !selection.assignedTasks!.contains(dataModel.getTaskFromString(taskName) as Any)) {
                                self.saveTaskToCoreData()
                                taskSheetOpen.toggle()
                            } else {
                                hapticError = true
                                // trigger the shake animation
                                withAnimation(.default) {
                                    attempts += 1
                                }
                            }
                        } label: {
                            Text("Save")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .sensoryFeedback(.error, trigger: hapticError) // haptic feedback
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Add Task").font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            taskSheetOpen.toggle()
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
        .onAppear {
            savedTags = dataModel.fetchSavedTags()
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
