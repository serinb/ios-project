//
//  AddTag.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 22.01.24.
//

import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR ADD TAG SHEET **/

struct AddTag: View {
    
    @Binding var tagSheetOpen: Bool   // Bool value to open/close the sheet
    @State private var tagName = ""   // Tag name textfield variable
    @State var attempts: Int = 0      // counter for the shake animation
    
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
            Form {
                // Textfield for tag name input
                Section {
                    TextField("Enter tag name", text: $tagName)
                        .font(fontSizeSelection.fontSizePick)
                        .modifier(Shake(animatableData: CGFloat(attempts))) // shake animation modifier
                }
            }
            .toolbar {
                // Save tag button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if tagName != "" {
                            // Save to Core Data
                            dataModel.saveTagToCoreData(tagName)
                            tagSheetOpen.toggle()
                        } else {
                            hapticError = true
                            // trigger the shake animation
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
                    Text("Add Tag").bold().font(fontSizeSelection.fontSizePick)
                }
                // Close button to cancel
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        tagSheetOpen.toggle()
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

#Preview {
    TaskListView()
}
