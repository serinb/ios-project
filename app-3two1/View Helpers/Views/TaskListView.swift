//
//  ProjectsView.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 16.12.23.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    // States for the sheets
    @State private var isSettingsAlertPresented = false
    @State public var projectSheetOpen = false
    @State public var taskSheetOpen = false
    @State public var tagSheetOpen = false
    @State public var folderChosen = false
    @State public var editTaskSheetOpen = false
    @State public var editProjectSheet = false
    @State public var completeProjectSheet = false
    
    //Textfield/SearchField input
    @State private var taskName = ""
    @State private var projectName = ""
    @State private var searchText = ""
    
    // Core Data arrays and items
    @State public var savedProjects: [Project] = []
    @State public var chosenProject: [Project] = []
    @State private var savedTasks: [Task] = []
    @State public var savedTags: [Tag] = []
    @State public var currentProjectTrue: [Bool] = []
    @State public var currentProjectIndex = 0
    @State public var selectedTags: Set<Tag> = []
    @State private var selectedTasks = Set<Task>()
    @State private var selectedTasksBackUp = Set<Task>()
    @State public var taskToEdit: Task? = nil
    @State public var projectForTask: Project? = nil
    @State private var selectedTag: Tag? = nil
    
    //Not sure to be honest
    @State private var currentlyTrue = false
    @State private var isFilled: Bool = false
    @State public var allTasksChosen = true
    
    //Update view
    @State public var refreshID = UUID()
    @State public var updater = false
    
    //Haptics
    @State private var hapticComplete = false
    

    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //Edit Mode
    @Environment(\.editMode) private var editMode

    
    var body: some View {
        NavigationStack{
            //Bar at the top of view where users can choose a project to filter tasks
            ProjectBar(allTasksChosen: $allTasksChosen, savedProjects: $savedProjects, chosenProject: $chosenProject, currentProjectTrue: $currentProjectTrue, currentProjectIndex: $currentProjectIndex, isSettingsAlertPresented: $isSettingsAlertPresented, editProjectSheet: $editProjectSheet, completeProjectSheet: $completeProjectSheet)
            ZStack {
                /** TASK LIST **/
                List(selection: $selectedTasks) {
                    ForEach(filteredTasks, id: \.self){ task in
                        Section {
                            //filtered tasks by tag and or project
                            if allTasksChosen == false && task.originProject == chosenProject[0] {
                                //View for each list item depicting Task
                                TaskView(taskSheetOpen: $taskSheetOpen, editTaskSheetOpen: $editTaskSheetOpen, taskToEdit: $taskToEdit, givenTask: task)
                                //swipe to complete task
                                    .swipeActions(edge: .leading) {
                                        Button("", systemImage: "checkmark") {
                                            if task.taskCompleted == true {
                                                task.taskCompleted = false
                                            }
                                            else {
                                                hapticComplete = true
                                                task.taskCompleted = true
                                            }
                                            self.fetchSavedTasks()
                                            self.refreshID = UUID()
                                        }
                                        .sensoryFeedback(.success, trigger: hapticComplete) // haptic feedback
                                        .tint(colorThemeSelection.colorAccentPick)
                                    }
                                // swipe to edit task
                                    .swipeActions(edge: .leading) {
                                        Button("", systemImage: "pencil") {
                                            taskToEdit = task
                                            projectForTask = task.originProject
                                            print(projectForTask!.name!)
                                            editTaskSheetOpen.toggle()
                                        }
                                        .tint(colorThemeSelection.colorAccentPick.opacity(0.8))
                                    }
                            }
                            //all tasks
                            else if allTasksChosen == true {
                                TaskView(taskSheetOpen: $taskSheetOpen, editTaskSheetOpen: $editTaskSheetOpen, taskToEdit: $taskToEdit, givenTask: task)
                                // swipe to complete task
                                    .swipeActions(edge: .leading) {
                                        Button("", systemImage: "checkmark") {
                                            if task.taskCompleted == true {
                                                task.taskCompleted = false
                                            }
                                            else {
                                                task.taskCompleted = true
                                            }
//                                            self.fetchSavedTags()
//                                            self.fetchSavedTasks()
//                                            self.fetchSavedProjects()
//                                            self.loadProjects()
                                            self.refreshID = UUID()
                                        }
                                        .tint(colorThemeSelection.colorAccentPick)
                                    }
                                //swipe to edit task
                                    .swipeActions(edge: .leading) {
                                        Button("", systemImage: "pencil") {
                                            taskToEdit = task
                                            projectForTask = task.originProject
                                            print(projectForTask!.name!)
                                            editTaskSheetOpen.toggle()
                                        }
                                        .tint(colorThemeSelection.colorAccentPick.opacity(0.8))
                                    }
                            }
                        }
                        .listRowBackground(Color.whiteBlack)
                    }
                    .onDelete(perform: deleteSavedTask)
                    Spacer()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    Spacer()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                }
                .ignoresSafeArea(.all, edges: [.bottom])
                .id(refreshID)
                .padding(.top, 10)
                .background(colorThemeSelection.colorAccentPick.opacity(0.2))
                .scrollContentBackground(.hidden)
                .clipShape(
                    .rect(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20
                    )
                )
                .listSectionSpacing(.compact)
                .listStyle(.insetGrouped)
                
                /** TOOLBAR **/
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack{
                            EditButton()
                            ToolBar(selectedTags: $selectedTags, selectedTasks: $selectedTasks, selectedTasksBackUp: $selectedTasksBackUp, savedTags: $savedTags, folderChosen: $folderChosen, updater: $updater)
                        }
                        // Add project
                        .sheet(isPresented: $projectSheetOpen, onDismiss: didDismiss, content: {
                            AddProject(projectSheetOpen: $projectSheetOpen)
                                .presentationDetents([.fraction(0.2), .medium])
                                .presentationDragIndicator(.visible)
                                .presentationBackground(.clear)
                        })
                        //Add task
                        .sheet(isPresented: $taskSheetOpen, onDismiss: fetchSavedTasks, content: {
                            if let firstProject = savedProjects.first {
                                AddTask(taskSheetOpen: $taskSheetOpen, savedProjects: $savedProjects, savedTasks: $savedTasks, savedTags: $savedTags, selection: firstProject)
                                    .presentationDetents([.fraction(0.5), .large])
                                    .presentationDragIndicator(.visible)
                                    .presentationBackground(.clear)
                            } else {
                                // Handle the case when savedProjects is empty
                                Text("No projects available")
                            }
                        })
                        // Add tag
                        .sheet(isPresented: $tagSheetOpen, onDismiss: fetchSavedTags, content: {
                            AddTag(tagSheetOpen: $tagSheetOpen)
                                .presentationDetents([.fraction(0.2), .medium])
                                .presentationDragIndicator(.visible)
                                .presentationBackground(.clear)
                        })
                        // Choose project to move tasks to
                        .sheet(isPresented: $folderChosen, onDismiss: didDismissChoose, content: {
                            if !savedProjects.isEmpty {
                                SortIntoProject(folderChosen: $folderChosen, savedProjects: $savedProjects, selectedTasks: selectedTasksBackUp, selection: savedProjects.first!)
                            }
                        })
                        //Edit Task
                        .sheet(isPresented: $editTaskSheetOpen, onDismiss: fetchSavedTasks, content: {
                            EditTask(editTaskSheetOpen: $editTaskSheetOpen, taskToEdit: $taskToEdit, savedProjects: $savedProjects, savedTags: $savedTags, refreshID: $refreshID)
                                .presentationDetents([.fraction(0.4), .large])
                                .presentationDragIndicator(.visible)
                                //removes solid background behind sheet
                                //that way settingsview is visible
                                .presentationBackground(.clear)
                        })
                        //Delete Project
                        .sheet(isPresented: $isSettingsAlertPresented, onDismiss: didDismiss, content: {
                            if !savedProjects.isEmpty {
                                DeleteProject(isSettingsAlertPresented: $isSettingsAlertPresented, savedProjects: $savedProjects, savedTasks: $savedTasks, selection: savedProjects.first!)
                                    .presentationDetents([.fraction(0.2), .medium])
                                    .presentationDragIndicator(.visible)
                            }
                        })
                        // Complete Project
                        .sheet(isPresented: $completeProjectSheet, onDismiss: didDismiss, content: {
                            if !savedProjects.isEmpty {
                                CompleteProject(completeProjectSheet: $completeProjectSheet, savedProjects: $savedProjects, selection: savedProjects.first!)
                                    .presentationDetents([.fraction(0.2), .medium])
                                    .presentationDragIndicator(.visible)
                            }
                        })
                        //Edit Project
                        .sheet(isPresented: $editProjectSheet, onDismiss: fetchSavedProjects, content: {
//                            print(taskToEdit!.name!)
                            EditProject(editProjectSheet: $editProjectSheet, savedProjects: $savedProjects, refreshID: $refreshID, selection: savedProjects.first!)
                                .presentationDetents([.fraction(0.4), .medium])
                                .presentationDragIndicator(.visible)
                                .presentationBackground(.clear)
                        })
                    }
                }
                .searchable(text: $searchText, placement: .toolbar)
                .navigationTitle("Tasks")
                
                
                /** ADD BUTTON IN BOTTOM RIGHT **/
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()

                        Menu {
                            //Add Project
                            Button {
                                projectSheetOpen.toggle()
                            } label: {
                                Image(systemName: "figure.stairs")
                                Text("Add Project")
                                    .font(fontSizeSelection.fontSizePick)
                            }
                            //Add Task
                            Button {
                                taskSheetOpen.toggle()
                            } label: {
                                Image(systemName: "checklist.unchecked")
                                Text("Add Task")
                                    .font(fontSizeSelection.fontSizePick)
                            }
                            //Add Tag
                            Button {
                                tagSheetOpen.toggle()
                            } label: {
                                Image(systemName: "tag")
                                Text("Add Tag")
                                    .font(fontSizeSelection.fontSizePick)
                            }
                        } label: {
                            Image(systemName: "plus").resizable().frame(width: 30, height: 30).foregroundColor(.standardTheme)
                        }
                        .frame(width: 60, height: 60)
                        .background(colorThemeSelection.colorAccentPick)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
             
        }
        .environment(\.colorScheme, displayTheme.themePick!)
        .onAppear {
            // Fetch saved items from Core Data
            self.fetchSavedTags()
            self.fetchSavedTasks()
            self.fetchSavedProjects()
            self.loadProjects()
        }
    }
    
    //Fetch all Projects from Core Data
    private func fetchSavedProjects() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            self.savedProjects = try context.fetch(Project.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
    //Fetch all Tasks from Core Data
    private func fetchSavedTasks() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            self.savedTasks = try context.fetch(Task.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
    //Fetch all Tags from Core Data
    private func fetchSavedTags() {
        let context = PersistenceController.shared.container.viewContext
        do {
            // Fetch items from Core Data
            self.savedTags = try context.fetch(Tag.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
    //Delete a given task from CoreData
    private func deleteSavedTask(at offsets: IndexSet) {
        let context = PersistenceController.shared.container.viewContext
        // Delete item from Core Data model
        for index in offsets {
            let taskToDelete = savedTasks[index]
            context.delete(taskToDelete)
        }
        
        // Save context after deletion
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
        self.fetchSavedTasks()
    }
    
    //Additional processing to display all projects correctly
    private func loadProjects() {
        currentProjectTrue = []
        currentProjectTrue += [true]
        currentProjectIndex = 0
        for _ in savedProjects {
            currentProjectTrue.append(false)
        }
        if currentProjectTrue == []
        {
            print("Yes")
            currentProjectTrue.append(false)
        }
    }
    
    //Additional processing to add project
    private func didDismiss() {
        self.fetchSavedProjects()
        self.loadProjects()
    }
    
    //Additional processing to move task
    private func didDismissChoose() {
        self.fetchSavedProjects()
        self.fetchSavedTasks()
        editMode?.wrappedValue = .inactive
    }
    
    //Filter tasks by tag
    var filteredTasks: [Task] {
        guard !searchText.isEmpty else {
            if !selectedTags.isEmpty {
                return savedTasks.filter { task in
                    if let taskTags = task.assignedTags {
                        let taskTagSet = Set(taskTags.compactMap { $0 as? Tag })
                        return !selectedTags.isDisjoint(with: taskTagSet)
                    }
                    return false
                }
            } else if let selectedTag = selectedTag {
                return savedTasks.filter { task in
                    if let taskTags = task.assignedTags {
                        let taskTagSet = Set(taskTags.compactMap { $0 as? Tag })
                        return taskTagSet.contains(selectedTag)
                    }
                    return false
                }
            } else {
                return savedTasks
            }
        }
        return savedTasks.filter { task in
            task.name!.lowercased().contains(searchText.lowercased())
        }
    }
}

#Preview {
    TaskListView()
}
