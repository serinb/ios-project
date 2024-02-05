//
//  OnBoardingView.swift
//  app-3two1
//
//  Created by Serin on 22.01.24.
//


import SwiftUI
import AVKit

struct OnboardingView: View {
    //saves the current state of the dl mode, default is set to light mode
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    //keeps track of the current sheet in view
    @State var currSheet = 0
    //toggle state for when the onboarding is open/closed
    @AppStorage("showOnBoarding") var showOnBoarding: Bool = true
    //saves the current username
    @AppStorage("username") var username: String = ""
    
    // shake animation
    @State private var attempts: Int = 0

    var body: some View {
        NavigationView {
            TabView(selection: $currSheet) {
                ForEach(1..<5) { i in
                    VStack {
                        /** ONBOARDING SHEET CONTENT **/
                        if(currSheet == 0) {
                            firstSheetContent()
                                .padding(.top, 40)
                        }
                        else if(currSheet == 1) {
                            secondSheetContent(attempts: attempts)
                                .padding(.top, 50)
                        }
                        else if(currSheet == 2) {
                            thirdSheetContent()
                                .padding(.top, 40)
                        }
                        else if(currSheet == 3) {
                            forthSheetContent()
                                .padding(.top, 40)
                        }
                        
                        Spacer()
                        
                        HStack {
                            if (currSheet >= 1)
                            {
                                /** BACK BUTTON **/
                                Button {
                                    currSheet -= 1
                                } label: {
                                    ZStack {
                                        Circle()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.black)
                                        Image(systemName: "arrow.backward")
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(.top, -70)
                                .padding()
                            }
                            
                            Spacer()
                            
                            /** NEXT BUTTON **/
                            Button {
                                //for ENTER NAME sheet only allow next if username not empty
                                if (currSheet == 1 && username.isEmpty) {
                                    // trigger shake animation
                                    withAnimation(.default) {
                                        attempts += 1
                                    }
                                    currSheet = currSheet
                                }
                                //else allow next
                                else if (currSheet == 0 || currSheet == 2 || (currSheet == 1 && !username.isEmpty)) {
                                    
                                    currSheet += 1
                                }
                                //for GET STARTED btn, exit onboarding
                                else {
                                    currSheet = 0
                                    showOnBoarding.toggle()
                                }
                            } label: {
                                if (currSheet == 0 || currSheet == 2 || currSheet == 1) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.black)
                                        Image(systemName: "arrow.forward")
                                            .foregroundStyle(.white)
                                    }
                                }
                                //for GET STARTED btn, exit onboarding
                                else {
                                    ZStack {
                                        Text("Get Started!")
                                            .padding()
                                            .font(fontSizeSelection.fontSizePick)
                                            .foregroundStyle(.white)
                                            .background {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .foregroundColor(.black)
                                            }
                                    }
                                }
                            }
                            .padding(.top, -70)
                            .padding()
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                }
                //background colors for onboarding sheets
                .background {
                switch currSheet {
                case 0:
                    Color.greenOB
                case 1:
                    Color.redOB
                case 2:
                    Color.purpleOB
                case 3:
                    Color.blueOB
                default:
                    Color.gray
                }
            }
            .onAppear {
                  UIScrollView.appearance().isScrollEnabled = false
                }
            .animation(.easeInOut, value: currSheet)
            .tabViewStyle(.page)
            .ignoresSafeArea()
            .environment(\.colorScheme, .light)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
