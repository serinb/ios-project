//
//  MultipleTags.swift
//  app-3two1
//
//  Created by Elisabeth Buttkus on 28.01.24.
//

import SwiftUI
import CoreData

struct MultipleTags: View {
    
    //Paramneters for view
    @Binding var savedTags: [Tag]
    @Binding var selectedTags: [Tag]
    //Bool for sheet
    @State private var tagSheetOpen = false
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //Allows the user to choose multiple tags
    var body: some View {
        //List of all tags
        List {
            ForEach(savedTags, id: \.self){ someTag in
                HStack{
                    Button {
                        if self.checkForTag(someTag: someTag) == true {
                            updateSelection(someTag: someTag)
                        }
                        else {
                            selectedTags.append(someTag)
                        }
                    } label: {
                        //The user selected tags are checkmarked
                        HStack{
                            Image(systemName: "checkmark")
                                .opacity(checkForTag(someTag: someTag) ? 1 : 0)
                            Text(someTag.name!)
                        }
                    }
                }
            }
            Button {
                tagSheetOpen.toggle()
            } label: {
                HStack{
                    Image(systemName: "plus")
                    Text("Add Tags")
                }
            }
        }
        //Sheet to add additional tags
        .sheet(isPresented: $tagSheetOpen, onDismiss: fetchSavedTags, content: {
            AddTag(tagSheetOpen: $tagSheetOpen)
                .presentationDetents([.fraction(0.2), .medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.standardTheme)
        .environment(\.colorScheme, displayTheme.themePick!)
    }
    
    // Get tags from Core Data
    private func fetchSavedTags() {
        let context = PersistenceController.shared.container.viewContext
        do {
            // Fetch items from Core Data
            self.savedTags = try context.fetch(Tag.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
    //Support function to find tag
    private func checkForTag(someTag: Tag) -> Bool {
        for selectedTag in selectedTags {
            if selectedTag == someTag {
                return true
            }
        }
        return false
    }
    
    //Support function to update the tag selection
    private func updateSelection(someTag: Tag) {
        var tempTags: [Tag] = []
        for selectedTag in selectedTags {
            if selectedTag != someTag {
                tempTags.append(selectedTag)
            }
        }
        selectedTags = tempTags
        
    }
    
}

#Preview {
    TaskListView()
}
