
//  AddProject.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 20.01.24.
//

/* This view (sheet) allows the user to add projects. Empty input is not accepted. The only necessary input is a project name.*/

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR ADD PROJECT SHEET **/

struct AddProject: View {
    
    @Binding var projectSheetOpen: Bool     // Bool value to open/close the sheet
    @State private var projectName = ""     // project name textfield variable
    @State var attempts: Int = 0            // counter for the shake animation
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //Include core data class for funtionality
    var dataModel = CoreDataModel()
    
    @State private var hapticError = false
    
    var body: some View {
        NavigationView{
            Form{
                // Textfield for project name input
                Section {
                    //Text Field for project name
                    TextField("Enter project name", text: $projectName)
                        .font(fontSizeSelection.fontSizePick)
                        .modifier(Shake(animatableData: CGFloat(attempts))) // shake animation modifier
                }
                .toolbar {
                    // Save project button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if projectName != "" {
                                // Save to Core Data
                                dataModel.saveProjectToCoreData(name: projectName) //saving the project into CoreData
                                projectSheetOpen.toggle()
                            } else {
                                // trigger the shake animation
                                hapticError = true
                                withAnimation(.default) {
                                    attempts += 1
                                }
                            }
                            
                            
                        } label: {
                            Text("Save").bold().foregroundStyle(colorThemeSelection.colorAccentPick).font(fontSizeSelection.fontSizePick)
                        }
                        .sensoryFeedback(.error, trigger: hapticError) // haptic feedback
                    }
                    // Sheet Title
                    ToolbarItem(placement: .principal) {
                        Text("Add Project").bold().font(fontSizeSelection.fontSizePick)
                    }
                    // Close button to cancel
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            projectSheetOpen.toggle()
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

#Preview {
   TaskListView()
}
