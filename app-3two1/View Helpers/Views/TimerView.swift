//
//  TimerView.swift
//  app-3two1
//
//  Created by Martin Zakrzewski on 17.12.23.
//

import SwiftUI
import CoreData

struct TimerView: View {
    
    //saves the current state of the dl mode, default is set to light mode
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    // provides most properties and functions
    @ObservedObject private var viewModel = TimerViewModel()
    
    // gets updated by picker view
    @State var selectedProject = ""
    @State var selectedTask = ""
    @State var isProjectSheetPresented = false

    // provide projects for picker
    @State var projectsToPick=[Project]()
    
    // to show new task sheet
    @State var showNextTaskSheet = false
     
    // update provided projects for picker
    func fetchProjectsForPicker() {
        projectsToPick = []

        for project in viewModel.fetchSavedProjects() {
            projectsToPick.append(project)
        }
    }
    
    // auto select the latest project
    func resetProjectSelection(){
        if(!projectsToPick.isEmpty){
            if let last = projectsToPick.last?.name {
                print("Reset to \(last)")
                selectedProject = last
            }
        }
        else {
            selectedProject = ""
        }
    }
    
    // check if selection is complete to enable tracking
    func checkCompletion(){
        
        if(selectedProject.isEmpty || selectedTask.isEmpty){
            print("set to incomplete...")
            viewModel.selectionComplete = false
        }
        else {
            print("set to complete...")
            viewModel.selectionComplete = true
        }
    
    }
    
    // save item to core data
    func saveItem(){
        if let project = viewModel.getProjectFromString(selectedProject), let task  = viewModel.getTaskFromString(selectedTask) {
            viewModel.saveItemToCoreData(forProject: project, forTask: task, startTime: viewModel.startTime, endTime: viewModel.endTime)
            
            if(viewModel.getGoal() != 0) {
                print("added to progress")
                let tracks = viewModel.getTracks()+1
                print("change tracks to \(tracks)")

                viewModel.saveProgressToCoreData(goal: viewModel.getGoal(), tracks: tracks)
                
                viewModel.refreshProgress()
            }
        }
    }
    
    var body: some View {
            VStack {
                VStack {
                        // Progress bar
                        ProgressbarView(viewModel:viewModel)
                            .padding([.leading, .trailing], 10)
                            .padding(.bottom, 10)
                            .onTapGesture {
                            }
                    
                    HStack {
                        Button { // show next planned event (that hasn't ended yet)
                            showNextTaskSheet.toggle()
                            print(viewModel.selectionComplete)
                        } label: {
                            Image(systemName: "chevron.down")
                            Text("SEE NEXT TASK").font(Appearance().timerTextSmall)
                        }
 
                        Spacer()
                        
                        // toggle to change way of tracking
                        Toggle(isOn: $viewModel.isToggleOn) {}
                            .disabled(viewModel.isTimerRunning)
                        if(viewModel.isToggleOn) {
                            Text("↑")
                        } else {
                            Text("↓")
                        }
                        
                    }
                    .padding(.top, -50)
                    .padding()
                    
                    // CIRCULAR COUNTDOWN OR STOPWATCH VIEW
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        // For iPad, make the circular part bigger
                        VStack {
                            if(viewModel.isToggleOn) {
                                StopwatchView(viewModel: viewModel)
                                    .onAppear{
                                        if(!viewModel.isTimerRunning){
                                            viewModel.resetStopwatch()
                                        }
                                    }
                                    .padding([.leading, .trailing], 30) // Adjust the padding for iPad
                                    .padding(.top, 100) // Adjust the padding for iPad
                                    .padding(.bottom, 80) // Adjust the padding for iPad
                            } else {
                                CountdownSliderView(viewModel: viewModel)
                                    .onAppear{
                                        if(!viewModel.isTimerRunning){
                                            viewModel.resetCountdown()
                                        }
                                    }
                                    .padding([.leading, .trailing], 30) // Adjust the padding for iPad
                                    .padding(.top, 100) // Adjust the padding for iPad
                                    .padding(.bottom, 80) // Adjust the padding for iPad
                            }
                        }
                    } else {
                        // For other devices, keep the original size
                        if(viewModel.isToggleOn) {
                            StopwatchView(viewModel: viewModel)
                                .onAppear{
                                    if(!viewModel.isTimerRunning){
                                        viewModel.resetStopwatch()
                                    }
                                }
                                .padding([.leading, .trailing], 10)
                                .padding(.top, 30)
                                .padding(.bottom, 10)
                        } else {
                            CountdownSliderView(viewModel: viewModel)
                                .onAppear{
                                    if(!viewModel.isTimerRunning){
                                        viewModel.resetCountdown()
                                    }
                                }
                                .padding([.leading, .trailing], 10)
                                .padding(.top, 30)
                                .padding(.bottom, 10)
                        }
                    }
                }
                
                // show upcoming task
                .sheet(isPresented: $showNextTaskSheet, content: {
                    VStack {
                        NextTodoView(viewModel:viewModel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.standardTheme)
                    .environment(\.colorScheme, displayTheme.themePick!)
                    .presentationDetents([.fraction(0.4), .medium])
                    .presentationDragIndicator(.visible)
                })
                .background(.whiteBlack)
                .padding(.bottom, 40)
                
                
                VStack {
                    // PICKER VIEW
                    PickerView(projectsToPick: $projectsToPick, selectedProject: $selectedProject, selectedTask: $selectedTask, isProjectSheetPresented: $isProjectSheetPresented)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .background(colorThemeSelection.colorAccentPick.opacity(0.2))
                .clipShape(
                    .rect(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20
                    )
                )
            }

             // updates projects picker and sets selection to last projects
             .onAppear {
               fetchProjectsForPicker()
               resetProjectSelection()
               checkCompletion()
                 
                 
                 viewModel.refreshProgress()
       
             }
             // open project sheet and update project picker after closing
             .sheet(isPresented: $isProjectSheetPresented, onDismiss: {
                 isProjectSheetPresented = false
                 fetchProjectsForPicker()
                 resetProjectSelection()
                 
             }) {
                 AddProject(projectSheetOpen: $isProjectSheetPresented)
             }
        
             // start timer without selections
             .alert("Selection Not Completed", isPresented: $viewModel.noSelectionAlert) {
                 Button("OK",action: {
                     viewModel.noSelectionAlert = false
             })
             } message: {
                 Text("Please select a project and task or create new ones")
             }
             
             // signalization to save item
             .onChange(of:viewModel.saveToggle){
                 saveItem()
             }
            
            // check completion of selection with every change of it
             .onChange(of:selectedProject){
                 checkCompletion()
             }
             .onChange(of:selectedTask){
                 checkCompletion()
             }
         }
        
}

#Preview {
    ContentView()
}



