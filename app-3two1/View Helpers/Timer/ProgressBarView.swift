//
//  ProgressBarView.swift
//  app-3two1
//
//  Created by Chantal Rohde on 25.01.24.
//
import SwiftUI
import CoreData
import Foundation

/** CONTAINS THE STRUCTURE FOR PROGRESSBAR **/

struct ProgressbarView: View { // indicates ratio of planned events and actual tracked events
    
    // get required properties and methods
    @ObservedObject var viewModel: TimerViewModel

    //saves the current state of the dl mode, default is set to light mode
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    var body: some View{
            VStack(alignment:.leading){
                HStack {
                    Text("TODAY'S PROGRESS").font(Appearance().timerTextSmall)
                        .padding(.leading, 15)
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    // number of tracked times / tracking goal
                    Text("\(viewModel.getTracks()) / \(viewModel.getGoal())").font(Appearance().timerTextSmall).padding(.trailing)
                }

            ZStack(alignment:.leading){

                Capsule()
                    .fill(colorThemeSelection.colorAccentPick.opacity(0.2))
                    .frame(height:22)

                Capsule()
                    .fill(LinearGradient(gradient: .init(colors:[Color(.redTheme),Color(.greenTheme), Color(.blueTheme)]), startPoint: .leading, endPoint: .trailing))
                    .frame(width:viewModel.percent, height:22)
            }
            .onTapGesture {
                // trigger sheet
                viewModel.showProgressSheet.toggle()
            }
                
            // set progress goals
            .sheet(isPresented: $viewModel.showProgressSheet, content: {
                VStack {
                    ProgressBarSheet(viewModel:viewModel)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.standardTheme)
                .environment(\.colorScheme, displayTheme.themePick!)
                .presentationDetents([.fraction(0.4), .medium])
                .presentationDragIndicator(.visible)
            })
            .background(.whiteBlack)
            .padding(.bottom, 40)
            .animation(.spring, value:viewModel.percent)
            .padding([.leading, .trailing], 10)
            .padding(.bottom, 10)
            .cornerRadius(15)
        }
    }
}

#Preview {
    ContentView()
}

