//
//  TaskView.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 21/12/2023.
//

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR TASK ITEM BOX **/

struct TaskView: View {
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") var fontSizeSelection: FontSelection = .regular
    
    //Bools for sheets
    @Binding var taskSheetOpen: Bool
    @Binding var editTaskSheetOpen: Bool
    
    //task for this view
    @Binding var taskToEdit: Task?
    
    var givenTask: Task
    
    //Depict the individual tasks (which are part of the task list)
    var body: some View {
        VStack { // Two layers: 1. Picture, Title, Tags; 2. Date, timespent
            HStack {
                VStack {
                    HStack {
                        ZStack {
                            //Image for task
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.blackWhite)
                                .frame(width: 40, height: 40)
                            if givenTask.picture != nil {
                                Image(systemName: givenTask.picture!)
                                    .foregroundStyle(.blackWhite)

                            }
                            else {
                                Image(systemName: "studentdesk")
                                    .foregroundStyle(.blackWhite)
                            }
                        }
                        
                        VStack {
                            //Task name
                            Text(givenTask.name!)
                                .font(Appearance().taskViewTaskName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            //Project of the task
                            Text(givenTask.originProject!.name!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(Appearance().taskViewProjectName)

                        }
                        //Checkmark if task is completed
                        if givenTask.taskCompleted == true {
                            Image(systemName: "checkmark")
                                .foregroundStyle(colorThemeSelection.colorAccentPick)
                        }
                        //Button to edit tasks
                        Button {
                            taskToEdit = givenTask
                            editTaskSheetOpen.toggle()
                            print("Button clicked!")
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(-90))
                                .foregroundStyle(colorThemeSelection.colorAccentPick)
                                .padding([.top, .trailing], -10)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    //Tags of the task
                    HStack {
                        if givenTask.assignedTags != []
                        {
                            ForEach(Array((givenTask.assignedTags!.array as! [Tag]).enumerated()), id: \.offset) { index, tag in
                                if index <= 2 {
                                    TagView(tag: tag)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5)
                }
            }
        }
    }
}

//Depicting a Tag in a rounded box
struct TagView: View {
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var tag: Tag
    
    var body: some View {
        Text(tag.name!)
            .font(fontSizeSelection.fontSizePick)
            .padding(5)
            .font(.footnote)
            .foregroundColor(.gray)
            .background(
                Capsule()
                    .stroke(.gray)
                    
            )
    }
}

#Preview {
    TaskListView()
}
