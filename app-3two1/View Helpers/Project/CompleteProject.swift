//
//  CompleteProject.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 27.01.24.
//

import SwiftUI
import CoreData

struct CompleteProject: View {
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    @Binding var completeProjectSheet: Bool
    @Binding var savedProjects: [Project]
    //@State private var closeAlert = false
    
    //Haptic Feedback
    @State private var hapticComplete = false

    @State var selection: Project
    
    var body: some View {
        NavigationView{
            Form {
                Section {
                    Picker(selection: $selection, label: Text("Choose a project to mark as complete").font(fontSizeSelection.fontSizePick)) {
                        ForEach(savedProjects, id: \.self) {
                            Text($0.name!)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                }
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            selection.projectCompleted.toggle()
                            self.fetchSavedProjects()
                            hapticComplete = true
                            completeProjectSheet.toggle()
                        } label: {
                            Text("Save")
                                .font(fontSizeSelection.fontSizePick)
                                .bold()
                        }
                        .sensoryFeedback(.success, trigger: hapticComplete) // haptic feedback
                        .foregroundStyle(colorThemeSelection.colorAccentPick)
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Mark Project as Complete").bold().font(fontSizeSelection.fontSizePick)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            completeProjectSheet.toggle()
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
    
    private func fetchSavedProjects() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            self.savedProjects = try context.fetch(Project.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
}

#Preview {
    TaskListView()
}
