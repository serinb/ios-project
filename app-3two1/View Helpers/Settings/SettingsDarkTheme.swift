//
//  SettingsDarkTheme.swift
//  app-3two1
//
//  Created by Serin on 05.01.24.
//

import SwiftUI
import Foundation

/** CONTAINS THE LOGIC AND STRUCTURE FOR THE DARK AND LIGHT MODE SETTINGS **/

struct SettingsDarkTheme: View {
    //needed for keeping view up-to-date with current display theme and color accent
    @AppStorage("displayTheme") var displayTheme: ThemeSelection = .light
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    //for sliding animation in sheet
    @Namespace public var animation
    
    //addresses the current color scheme
    var currentScheme: ColorScheme

    //defined in SettingsView, used for showing/hiding DL mode sheet
    @Binding var  darkModeSheetOpen: Bool

    //used to address the custom font sizes
    var appearanceInstance = Appearance()

    var body: some View {
        
        //UI design for sliding sheet window
        VStack(spacing: 10) {

            VStack{
                //Title
                Text("Pick a Mode").frame(alignment: .center).bold()
                    .font(appearanceInstance.sheetTitle)
                
                //Image
                //if current selection dark, adjust image to moon
                if currentScheme == .dark {
                    Image(systemName: "moon.stars.fill").resizable().frame(width: 120, height: 120).foregroundStyle(displayTheme.theme(currentScheme).gradient).padding(.bottom, 20)
                }
                //else if light, adjust image to sun
                else if currentScheme == .light {
                    Image(systemName: "sun.max.fill").resizable().frame(width: 120, height: 120).foregroundStyle(displayTheme.theme(currentScheme).gradient).padding(.bottom, 20).padding(.top, 10)
                }
                
                //Sliding picker
                HStack(spacing: 0) {
                    //Theme contains cases dark and light
                    ForEach(ThemeSelection.allCases, id: \.rawValue) { theme in
                        //textual display each option and its format
                        Text(theme.rawValue)
                            .padding(.vertical, 10)
                            .frame(width: 100)
                            //mark selected option with a capsule shape
                            .background {
                                ZStack {
                                    if displayTheme == theme {
                                        Capsule()
                                            .fill(.standardTheme)
                                            .matchedGeometryEffect(id: "themeselection", in: animation)
                                    }
                                }
                                //creates a sliding animation when switching between options
                                .animation(.snappy, value: displayTheme)
                            }
                            .contentShape(.rect)
                            .onTapGesture {
                                //display theme is updated based on the currently selected option in the slider
                                displayTheme = theme
                            }
                    }
                    
                }
                .padding(3)
                .background(.primary.opacity(0.6), in: .capsule)
                .padding(.bottom, -20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.standardTheme)
        .clipShape(.rect(cornerRadius: 20))
        .padding(.horizontal, 20)
        .environment(\.colorScheme, currentScheme)

    }
}

#Preview {
    SettingsView()
}


