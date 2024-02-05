//
//  EditProject.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 27.01.24.
//

import SwiftUI

/** CONTAINS THE STRUCTURE FOR EDIT PROJECT SHEET **/

struct EditProject: View {
    @Binding var editProjectSheet: Bool
    @State private var projectName = ""
    @State private var closeAlert = false
    @Binding var savedProjects: [Project]
    @Binding var refreshID: UUID
    
    @State var selection: Project
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var body: some View {
        NavigationView{
            Form {
                Section {
                    Picker(selection: $selection,  label: Text("Choose a project to rename:").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {
                            Text($0.name!)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                .onChange(of: selection) {
                    projectName = selection.name!
                }
                Section(header: Text("New project name")
                    .font(Appearance().sectionTitle)
                    .foregroundColor(colorThemeSelection.colorAccentPick)) {
                    TextField("New project name", text: $projectName)
                        .font(fontSizeSelection.fontSizePick)
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 15))
                        .background(.standardTheme)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.saveProjectEdit()
                        self.refreshID = UUID()
                        editProjectSheet.toggle()
                    } label: {
                        Text("Save")
                            .font(fontSizeSelection.fontSizePick)
                            .bold()
                    }
                    .foregroundStyle(colorThemeSelection.colorAccentPick)
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Project").bold().font(fontSizeSelection.fontSizePick)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        editProjectSheet.toggle()
                    } label: {
                        Text("Close").foregroundStyle(colorThemeSelection.colorAccentPick).font(fontSizeSelection.fontSizePick)
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
        projectName = selection.name!
    }
    
    private func saveProjectEdit() {
        let context = PersistenceController.shared.container.viewContext
        selection.name = projectName // Save the provided name

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
