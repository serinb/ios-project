//
//  SettingsView.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 21/12/2023.
//

import SwiftUI

struct SettingsView: View {
    
    /** ONBOARDING **/
    @AppStorage("showOnBoarding") var showOnBoarding: Bool = true
    
    /** Dark/Light Mode (DL)  **/
    //saves the current state of the dl mode, default is set to light mode
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    
    //toggle state for when the DL settings sheet is open/closed
    @State public var darkModeSheetOpen = false
    
    //Environment variable for addressing the current set colorscheme
    //used for DL mode display in view
    @Environment(\.colorScheme) public var currentScheme
    
    /** Color Accent **/
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    
    //toggle state for when the color settings sheet is open/closed
    @State public var colorSheetOpen = false
    
    //saves the current set color accent
    var colorChoice = Color.accentColor
    
    /** Font **/
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //toggle state for when the font size settings sheet is open/closed
    @State public var fontSheetOpen = false
    
    //saves the current set font size
    @Environment(\.font) public var fontSizeChoice
    
    //used to address the custom font sizes
    var appearanceInstance = Appearance()
    
    
    /** Name **/
    @AppStorage("username") var username: String = ""
    
    /** Notifications **/
    
    //button toggle
    @State var pressedAllowNotificatons = false
    @State private var attemptsAllowNotifications: Int = 0

    @State var pressedDailyNotificatons = false
    @State private var attemptsDailyNotifications: Int = 0

    var body: some View {
        
        NavigationView {
            
            Form {
                /**---- USERNAME  ----**/
                Section(header: Text("Username")
                    .font(appearanceInstance.sectionTitle)
                    .foregroundColor(colorThemeSelection.colorAccentPick)) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(colorThemeSelection.colorAccentPick)
                                .frame(width:28)
                            Image(systemName: "person.fill").resizable().frame(width: 15, height: 15).foregroundColor(.standardTheme)
                        }
                        
                        TextField("Enter your name", text: $username)
                            .frame(height: 10)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(.standardTheme)
                            .cornerRadius(10)
                    }
                }
                
                /**---- APPEARANCE  ----**/
                Section(header: Text("Appearance")
                    .font(appearanceInstance.sectionTitle)
                    .foregroundColor(colorThemeSelection.colorAccentPick)) {
                    
                    //Dark Theme
                    HStack {
                    
                        //change icon to moon if dark mode, and to sun if light mode
                        ZStack {
                            if  currentScheme == .dark {
                                Circle()
                                    .fill(colorThemeSelection.colorAccentPick)
                                    .frame(width:28)
                                Image(systemName: "moon.stars.fill").resizable().frame(width: 17, height: 17).foregroundColor(.standardTheme)
                            }
                            else if currentScheme == .light {
                                Circle()
                                    .fill(colorThemeSelection.colorAccentPick)
                                    .frame(width:28)
                                Image(systemName: "sun.max.fill").resizable().frame(width: 17, height: 17).foregroundColor(.standardTheme)
                            }
                        }
             
                        Button {
                            darkModeSheetOpen.toggle()
                        } label: {
                            Text("Display Theme").foregroundStyle(.blackWhite)
                        }
                        
                        .preferredColorScheme(displayTheme.themePick)
                        
                        //sliding sheet for DL mode
                        .sheet(isPresented: $darkModeSheetOpen, content: {
                            SettingsDarkTheme(currentScheme: currentScheme, darkModeSheetOpen: self.$darkModeSheetOpen)
                                //set sliding height for sheet
                                .presentationDetents([.fraction(0.4), .medium])
                                .presentationDragIndicator(.visible)
                                //removes solid background behind sheet
                                //that way settingsview is visible
                                .presentationBackground(.clear)
                        })
                        
                        Spacer()
                        
                        //shows current DL mode in Section-tab
                        Text("\(displayTheme.rawValue)").foregroundStyle(.gray).padding(.trailing, 3)
                        Image(systemName: "chevron.forward").resizable().frame(width: 5, height: 10)
                        
                    }

                    //Color Accent
                    HStack {
                        
                        //Color Accent icon
                        ZStack{
                            Circle()
                                .fill(colorThemeSelection.colorAccentPick)
                                //.fill(.teal)
                                .frame(width:28)
                            Image(systemName: "paintpalette.fill").resizable().frame(width: 17, height: 15).foregroundColor(.standardTheme)
                        }
                        
                        Button {
                            colorSheetOpen.toggle()
                        } label: {
                            Text("Color Accent").foregroundStyle(.blackWhite)
                        }
                        
                        .preferredColorScheme(displayTheme.themePick)
                        
                        //sliding sheet for Color Accent
                        .sheet(isPresented: $colorSheetOpen, content: {
                            SettingsColorsTheme(colorChoice: colorChoice, colorSheetOpen: self.$colorSheetOpen)
                            //set sliding height for sheet
                            .presentationDetents([.fraction(0.4), .medium])
                            .presentationDragIndicator(.visible)
                            //removes solid background behind sheet
                            //that way settingsview is visible
                            .presentationBackground(.clear)
                        })
                        Spacer()
                        
                        //shows current Color Accent in Section-tab
                        Text("\(colorThemeSelection.rawValue)").foregroundStyle(.gray).padding(.trailing, 3)
                        Image(systemName: "chevron.forward").resizable().frame(width: 5, height: 10)
                    }
                    
                    //Font Size
                    HStack {
                        
                        //FontSize icon
                        ZStack {
                            Circle()
                                .fill(colorThemeSelection.colorAccentPick)
                                //.fill(.red)
                                .frame(width: 28)
                            Image(systemName: "textformat.size").resizable().frame(width: 15, height: 10).foregroundColor(.standardTheme)
                        }
                        Button {
                            fontSheetOpen.toggle()
                        } label: {
                            Text("Text Size").foregroundStyle(.blackWhite)
                        }
                       

                        .preferredColorScheme(displayTheme.themePick)
                     
                        //sliding sheet for Color Accent
                        .sheet(isPresented: $fontSheetOpen, content: {

                            SettingsFontSizes(fontSizeChoice: fontSizeChoice ?? Font.regularFont(), fontSheetOpen: self.$fontSheetOpen)
                            //set sliding height for sheet
                            .presentationDetents([.fraction(0.4), .medium])
                            .presentationDragIndicator(.visible)
                            //removes solid background behind sheet
                            //that way settingsview is visible
                            .presentationBackground(.clear)
                        })
                         
                        Spacer()
                         
                        //shows current Font Sizes in Section-tab
                        Text("\(fontSizeSelection.rawValue)").foregroundStyle(.gray).padding(.trailing, 3)
                        Image(systemName: "chevron.forward").resizable().frame(width: 5, height: 10)
                        
                    }
                    
                }

                Section {

                    Button {
                        if (attemptsAllowNotifications == 0) {
                            attemptsAllowNotifications += 1
                            pressedAllowNotificatons.toggle()
                            withAnimation {
                                thirdSheetContent.notificationInstance.askForNotificationPermission()
                            }
                        }
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(colorThemeSelection.colorAccentPick)
                                    .frame(width:28)
                                Image(systemName: "bell.fill").resizable().frame(width: 15, height: 15).foregroundColor(.standardTheme)
                            }
                            Text("Enable Notifications").foregroundStyle(.blackWhite)
                            
                            if(pressedAllowNotificatons) {
                                Spacer()
                                Image(systemName: "checkmark").foregroundStyle(.blackWhite)
                            }
                        }
                    }
                    
                        Button {
                            if (attemptsDailyNotifications == 0) {
                                attemptsDailyNotifications += 1
                                pressedDailyNotificatons.toggle()
                                withAnimation {
                                    thirdSheetContent.notificationInstance.sendDailyNotfication()
                                }
                            }
                            
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(colorThemeSelection.colorAccentPick)
                                        .frame(width:28)
                                    Image(systemName: "bell.fill").resizable().frame(width: 15, height: 15).foregroundColor(.standardTheme)
                                }
                                Text("Allow Daily Notifications").foregroundStyle(.blackWhite)
                                
                                if(pressedDailyNotificatons) {
                                    Spacer()
                                    Image(systemName: "checkmark").foregroundStyle(.blackWhite)
                                }
                            }
                        }

                        Button {
                            thirdSheetContent.notificationInstance.sendTestingNotification(type: "time", timeIntervall: 5, title: "Hey " + username + "!", message: "This an example for a notification.")
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(colorThemeSelection.colorAccentPick)
                                        .frame(width:28)
                                    Image(systemName: "wrench.adjustable").resizable().frame(width: 15, height: 15).foregroundColor(.standardTheme)
                                }
                                Text("Test: Send Notificaton in 5s").foregroundStyle(.blackWhite)
                            }
                        }

                }   header: {
                        Text("Notifications")
                        .font(appearanceInstance.sectionTitle)
                        .foregroundColor(colorThemeSelection.colorAccentPick)
                    } footer: {
                            Text("To revert notification settings, please reinstall the app.").font(Appearance().sectionTitle)
                        }
                    
               
 
            
                
                Section(header: Text("Need Help?")
                    .font(appearanceInstance.sectionTitle)
                    .foregroundColor(colorThemeSelection.colorAccentPick)) {
                        Button {
                            showOnBoarding.toggle()
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(colorThemeSelection.colorAccentPick)
                                        .frame(width:28)
                                    Image(systemName: "questionmark").resizable().frame(width: 10, height: 15).foregroundColor(.standardTheme)
                                }
                                
                                Text("Revisit Onboarding").foregroundStyle(.blackWhite)
                            }
                        }
                }

                
            }
            //for setting the current global font size to this view
            .font(fontSizeSelection.fontSizePick)
        }
        //for displaying current DL mode in view
        .background(.whiteBlack)
        .environment(\.colorScheme, displayTheme.themePick!)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

#Preview {
    ContentView()
}

