//
//  ToolBar.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 26.01.24.
//

import SwiftUI

/** CONTAINS THE STRUCTURE FOR TOOLBAR **/

struct ToolBar: View {
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") var fontSizeSelection: FontSelection = .regular
    
    //EditMode
    @Environment(\.editMode) private var mode
    
    //Parameters for view
    @Binding var selectedTags: Set<Tag>
    @Binding var selectedTasks: Set<Task>
    @Binding var selectedTasksBackUp: Set<Task>
    @Binding var savedTags: [Tag]
    @Binding var folderChosen: Bool
    @Binding var updater: Bool
    
    var body: some View {
        HStack{
            if self.mode?.wrappedValue.isEditing ?? true {
                //Click to choose project to move task to
                Menu("Move", systemImage: "folder") {
                    Button("Move Tasks", systemImage: "folder") {
                        selectedTasksBackUp = selectedTasks
                        folderChosen.toggle()
                        updater.toggle()
                    }
                }
            }
            else {
                Menu {
                    //Filtering of tasks
                    Text("Filter tasks by:").font(fontSizeSelection.fontSizePick)
                    Divider()
                    Button{
                        selectedTags.removeAll()
                    } label: {
                        Text("All Tags").font(fontSizeSelection.fontSizePick)
                    }
                    //Filtering is possible for each tag
                    ForEach(savedTags, id: \.self) { tag in
                        Button {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        } label: {
                            HStack {
                                Text(tag.name ?? "")
                                    .font(fontSizeSelection.fontSizePick)
                                if selectedTags.contains(tag) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(savedTags.isEmpty ? .gray : colorThemeSelection.colorAccentPick)
                }
            }
        }
    }
}

#Preview {
    TaskListView()
}
