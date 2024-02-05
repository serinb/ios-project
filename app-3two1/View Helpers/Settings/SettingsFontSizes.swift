//
//  SettingsFontSizes.swift
//  app-3two1
//
//  Created by Serin on 14.01.24.
//

import SwiftUI

/** CONTAINS THE LOGIC AND STRUCTURE FOR THE DYNAMIC FONT SIZE SETTINGS **/

struct SettingsFontSizes: View {

    //needed for keeping view up-to-date with current display theme, color accent and font size
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //for sliding animation in sheet
    @Namespace public var animation
    
    //addresses the current font size
    var fontSizeChoice : Font
    
    //used to address the custom font sizes
    var appearanceInstance = Appearance()
    
    //defined in SettingsView, used for showing/hiding font sizes sheet
    @Binding var fontSheetOpen:Bool
    
    var body: some View {
        //UI design for sliding sheet window
        VStack(spacing: 10) {

            VStack{
                //Title
                Text("Pick a Text Size").frame(alignment: .center).bold()
                    .font(appearanceInstance.sheetTitle)
                
                //Quote that scales based on the current font size selection

                Text("\"Never regard study as a duty, but as the enviable opportunity to learn.\" (Albert Einstein)")
                    .italic()
                    .padding(15)
                    .multilineTextAlignment(.center)
                    .background(Rectangle().fill(colorThemeSelection.colorAccentPick).opacity(0.2).cornerRadius(10))
                    .frame(width: 250)
                    .font(fontSizeSelection.fontSizePick)
                    .padding(.bottom, 20).padding(.top, 20)

                
                //Sliding picker
                HStack(spacing: 0) {
                    //FontSelection contains all font size cases
                    ForEach(FontSelection.allCases, id: \.rawValue) { fontSizeItem in
                        //textual display each option and its format
                        Text(fontSizeItem.rawValue)
                            .padding(.vertical, 10)
                            .frame(width: 100)
                            //mark selected option with a capsule shape
                            .background {
                                ZStack {
                                    if fontSizeSelection == fontSizeItem {
                                        Capsule()
                                            .fill(.standardTheme)
                                            .matchedGeometryEffect(id: "fontSizeselection", in: animation)
                                    }
                                }
                                //creates a sliding animation when switching between options
                                .animation(.snappy, value: fontSizeSelection)
                            }
                            .contentShape(.rect)
                            .onTapGesture {
                                //fontSizeSelection is updated based on the currently selected option in the slider
                                fontSizeSelection = fontSizeItem
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
