//
//  SettingsColorsTheme.swift
//  app-3two1
//
//  Created by Serin on 06.01.24.
//

import SwiftUI

/** CONTAINS THE LOGIC AND STRUCTURE FOR THE COLOR THEME SETTINGS **/

struct SettingsColorsTheme: View {

    //needed for keeping view up-to-date with current display theme, color accent
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    //addresses the current font size
    var colorChoice: Color
    
    //for sliding animation in sheet
    @Namespace public var animation

    //defined in SettingsView, used for showing/hiding color accent sheet
    @Binding var colorSheetOpen: Bool
    
    //used to address the custom font sizes
    var appearanceInstance = Appearance()
    
    var body: some View {
        //UI design for sliding sheet window
        VStack(spacing: 10) {

            VStack{
                //Title
                Text("Pick a Color").frame(alignment: .center).bold()
                    .font(appearanceInstance.sheetTitle)
                
                //paint icon that changess its color based on the current color accent selection
                Image(systemName: "paintpalette.fill")
                    .resizable()
                    .frame(width: 130, height: 110)
                    .foregroundStyle(colorThemeSelection.colorAccentPick.gradient)
                    .padding(.bottom, 20).padding(.top, 10)

                //Sliding picker
                HStack(spacing: 0) {
                    //ColorSelection contains all font size cases
                    ForEach(ColorSelection.allCases, id: \.rawValue) { colorItem in 
                        //textual display each option and its format
                        Text(colorItem.rawValue)
                            .padding(.vertical, 10)
                            .frame(width: 100)
                        //mark selected option with a capsule shape
                            .background {
                                ZStack {
                                    if colorThemeSelection == colorItem {
                                        Capsule()
                                            .fill(.standardTheme)
                                            .matchedGeometryEffect(id: "colorselection", in: animation)
                                    }
                                }
                                //creates a sliding animation when switching between options
                                .animation(.snappy, value: colorThemeSelection)
                            }
                            .contentShape(.rect)
                            .onTapGesture {
                                //fontSizeSelection is updated based on the currently selected option in the slider
                                colorThemeSelection = colorItem
                            }
                    }
                    
                }
                .padding(3)
                .background(.primary.opacity(0.06), in: .capsule)
                .padding(.bottom, -20)
            }
            

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.standardTheme)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 20)
        .environment(\.colorScheme, displayTheme.themePick!)
        
    }
}

#Preview {
    SettingsView()
}

