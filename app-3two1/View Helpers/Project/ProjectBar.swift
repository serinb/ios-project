//
//  ProjectBar.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 26.01.24.
//

import SwiftUI

/** CONTAINS THE STRUCTURE FOR  PROJECT BAR**/

struct ProjectBar: View {
    
    //Parameters for view
    @Binding var allTasksChosen: Bool
    @Binding var savedProjects: [Project]
    @Binding var chosenProject: [Project]
    @Binding var currentProjectTrue: [Bool]
    @Binding var currentProjectIndex: Int
    //Bools for sheets
    @Binding var isSettingsAlertPresented: Bool
    @Binding var editProjectSheet: Bool
    @Binding var completeProjectSheet: Bool

    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    //View is responsible for the scroll view depicting all projects beneath search bar
    var body: some View {
        HStack {
            
            ScrollView(.horizontal) {
                HStack {
                    //All tasks option
                    Button {
                        allTasksChosen = true
                        currentProjectTrue[currentProjectIndex] = false
                        currentProjectIndex = 0
                        currentProjectTrue[currentProjectIndex] = true
                    } label: {
                        Text("All Tasks").font(fontSizeSelection.fontSizePick)
                    }
                    .frame(height: 20)
                    .padding(10)
                    .foregroundColor(allTasksChosen ? colorThemeSelection.colorAccentPick: .blackWhite)
                    .background(
                        Capsule()
                            .fill(allTasksChosen ? colorThemeSelection.colorAccentPick.opacity(0.2)  : .clear)
                            .stroke(allTasksChosen ? colorThemeSelection.colorAccentPick: .blackWhite, lineWidth: 1)
                    )
                    //Option for each project
                    ForEach(Array(savedProjects.enumerated()), id: \.element) { index, project in
                        Button {
                            currentProjectTrue[currentProjectIndex] = false
                            currentProjectIndex = index+1
                            currentProjectTrue[currentProjectIndex] = true
                            allTasksChosen = false
                            if chosenProject == [] {
                                chosenProject += [project]
                            }
                            else {
                                chosenProject[0] = project
                            }
                        } label: {
                            HStack{
                                Text(project.name!).font(fontSizeSelection.fontSizePick)
                                if project.projectCompleted == true {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .padding(10)
                        .foregroundColor(currentProjectTrue[index+1] ? colorThemeSelection.colorAccentPick : .blackWhite)
                        .background(
                            Capsule()
                                .fill(currentProjectTrue[index+1] ?colorThemeSelection.colorAccentPick.opacity(0.2)  : .clear)
                                .stroke(currentProjectTrue[index+1] ? colorThemeSelection.colorAccentPick : .blackWhite, lineWidth: 1)
                        )
                        
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
            }
            ZStack {
                Rectangle()
                    .frame(width: 60, height: 40)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: -1, y: 0)
                    .foregroundStyle(.whiteBlack)
                Rectangle()
                    .frame(width: 60, height: 55)
                    .foregroundStyle(.whiteBlack)
                //Buttons to complete, edit and delete projects
                Menu {
                    Button {
                        completeProjectSheet.toggle()
                    } label: {
                        Image(systemName: "checkmark")
                        Text("Mark as Complete")
                            .font(fontSizeSelection.fontSizePick)
                    }
                    Button {
                        editProjectSheet.toggle()
                    } label: {
                        Image(systemName: "pencil")
                        Text("Edit Project")
                            .font(fontSizeSelection.fontSizePick)
                    }
                    Button {
                        isSettingsAlertPresented.toggle()
                    } label: {
                        Image(systemName: "trash")
                        Text("Delete Project")
                            .font(fontSizeSelection.fontSizePick)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding([.top, .bottom], 10)
                        .padding([.leading, .trailing], 3)
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                        .rotationEffect(.degrees(-90))
                        .background {
                            RoundedRectangle(cornerRadius:5)
                                .fill(Color.clear)
                                .stroke(colorThemeSelection.colorAccentPick)
                        }
                }
                .padding(.trailing, 2)
            }
        }
    }
}

#Preview {
    TaskListView()
}


