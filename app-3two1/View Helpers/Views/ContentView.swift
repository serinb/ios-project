//
//  ContentView.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 21/12/2023.
//

import SwiftUI


struct ContentView: View {
    
    //to address the current display theme
    @AppStorage("displayTheme") var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to show the onboarding sheets
    @AppStorage("showOnBoarding") var showOnBoarding: Bool = true
    
    @State private var selection = 2
    
    var body: some View {
        //for displaying the onboarding
        if (showOnBoarding) {
            OnboardingView()
        }
        // for switcing to the app and also showing tab bar
        else {
            TabView(selection: $selection) {
                TaskListView()
                    .tabItem {
                        Label("Tasks", systemImage: "list.bullet")
                    }
                    .tag(0)
                CalendarView()
                    .tabItem {
                        Label("Planner", systemImage: "calendar")
                    }
                    .tag(1)
                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
                    .tag(2)
                ProgressView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(3)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(4)
            }
            .environment(\.colorScheme, displayTheme.themePick!)
            .accentColor(colorThemeSelection.colorAccentPick)
            .onAppear{
                selection = 2
                // workaround to make tab bar background appear in every view
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
}

#Preview {
    ContentView()
}

