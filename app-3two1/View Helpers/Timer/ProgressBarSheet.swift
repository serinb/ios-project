//
//  ProgressBarSheet.swift
//  app-3two1
//
//  Created by Chantal Rohde on 29.01.24.
//

import Foundation
import CoreData
import SwiftUI


struct ProgressBarSheet: View {
    
    @ObservedObject var viewModel: TimerViewModel
    
    
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var body: some View {
      
        VStack {
            /*
            HStack {
                Text("Number of achievements for the day").font(fontSizeSelection.fontSizePick).bold().padding(.top, 40)
            }
             */
            
            Picker("", selection: $viewModel.selectedGoal) {
                ForEach(viewModel.goalOptions, id: \.self) {number in
                    Text(String(number))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding(.bottom)
        
            Button(action: { // reset tracking goal
                viewModel.clearAllProgress()
                viewModel.resetPercent()
            }){
                Image(systemName:  "trash")
            }
    
        }
        //.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.standardTheme)
        .environment(\.colorScheme, displayTheme.themePick!)
   
        
    .onChange(of:viewModel.selectedGoal){ // save goal to core data and update progress bar
 
        viewModel.saveProgressToCoreData(goal: viewModel.selectedGoal, tracks: viewModel.getTracks())
        viewModel.refreshProgress()
    }
    }
}
