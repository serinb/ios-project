//
//  OnBoardingSheetContents.swift
//  app-3two1
//
//  Created by Serin on 23.01.24.
//

import Foundation
import SwiftUI
import AVKit

/** CONTAINS CONTENT FOR ONBOARDING EXPERIENCE**/
//each struct contains the content of the it's corresponding sheet (there are 4 sheets in total)

//Image References
//sheetImage1:
//This icon is provided by storyset (by Freepik) https://storyset.com/illustration/college-entrance-exam/bro
//sheetImage2:
//This icon is provided by storyset (by Freepik) https://storyset.com/illustration/thinking-face/bro
//sheetImage3:
//This icon is provided by storyset (by Freepik) https://storyset.com/illustration/push-notifications/bro


//first sheet content
/** WELCOME **/
struct firstSheetContent: View {
    
    var body: some View {
        VStack {
            Image(.sheetImage1)
                .resizable()
                .frame(width: 400, height: 400)
                .padding(.top, -30)
            
            Text("Welcome to 3two1!")
                .font(Appearance().obTitle)
                .foregroundStyle(.blackWhite)
                .multilineTextAlignment(.center).bold()
                .padding(.top, -20)
                .padding(.bottom, 20)
            
            Text("Master your studies and beat procrastination in\n 3-2-1!")
                .font(Appearance().obText)
                .foregroundStyle(.blackWhite)
                .multilineTextAlignment(.center)
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .padding(.top, 20)
                .lineSpacing(5)
        }
    }
}

//second sheet content
/** ENTER NAME **/
struct secondSheetContent: View {
    var attempts: Int   // shake animation
    @State var keyboardOffset: CGFloat = 0.0
    @AppStorage("username") var username: String = ""
    @State var showNameExplanation = false
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var body: some View {
        VStack {
            Image(.sheetImage2)
                .resizable()
                .frame(width: 300, height: 300)
            
            Text("What's your name?\n")
                .font(Appearance().obTitle)
                .foregroundStyle(.blackWhite)
                .multilineTextAlignment(.center)
                .bold()
            
            TextField("Enter your name", text: $username)
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .font(fontSizeSelection.fontSizePick)
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .background(Color.white)
                .cornerRadius(10)
                .padding(.top, -30)

            
                Button{
                    showNameExplanation.toggle()
                } label: {
                    Text("Why am I sharing my name?")
                        .foregroundStyle(.redTheme)
                        .font(Appearance().whyButton)
                }
                .padding(.top, 10)
                .alert(isPresented: $showNameExplanation) {
                    Alert(
                        title: Text("To provide to you a personalised experience:"),
                        message: Text("We would like to notify you about upcoming tasks and events by adressing you by your name."),
                        dismissButton: .destructive(Text("Close"))
                    )
                }
        }
        .offset(y: -self.keyboardOffset/4)
        .onAppear {
            //this is for pushing the content up when the keyboard appears
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main)
            { (notification) in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                self.keyboardOffset = keyboardFrame.height
            }
            //and for pushing back down when it disappears
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main)
            { (notification) in
                self.keyboardOffset = 0
            }
        }
    }
}

//third sheet content
/** NOTFICATIONS **/
struct thirdSheetContent: View {
    @AppStorage("username") var username: String = ""
    static let notificationInstance = NotificationHelper()
    @State var showNotificationExplanation = false
    
    var body: some View {
        VStack {
            Image(.sheetImage3).resizable().frame(width: 300, height: 300)

            Text("Can we send you notifications?" )
                .font(Appearance().obTitle)
                .foregroundStyle(.blackWhite)
                .multilineTextAlignment(.center)
                .bold()
                .padding()
                .padding(.top, 20)
            
            VStack {
                Button {
                    thirdSheetContent.notificationInstance.askForNotificationPermission()
                } label: {
                    Text("Manage Notification Permissions")
                        .foregroundStyle(Color.white)
                        .frame(width: 300, height: 50)
                }
                .background(Color.purple)
                .cornerRadius(10)
                .padding(.top, -10)
                
                Button{
                    showNotificationExplanation.toggle()
                } label: {
                    Text("Why should I allow notifications?")
                        .foregroundStyle(.purple)
                        .font(Appearance().whyButton)
                }
                .padding(.top, 10)
                //Notificaton Persmissions
                .alert(isPresented: $showNotificationExplanation) {
                    Alert(
                        title: Text("To help boost your productivity:"),
                        message: Text("We would like to notify you about tasks and events ahead of time."),
                        dismissButton: .destructive(Text("Close"))
                    )

                }
            }
            .padding(.leading, 60)
            .padding(.trailing, 60)
            .padding(.top, 30)
        }
    }
}

//forth sheet content
/** TUTORIAL VIDEO **/
struct forthSheetContent: View {
    @State private var isPlaying = false
    @State private var player: AVPlayer

    init() {
        // Inizilaize video player with file
        if let videoURL = Bundle.main.url(forResource: "Tutorial-video", withExtension: "mov") {
            self._player = State(initialValue: AVPlayer(url: videoURL))
        } else {
            fatalError("Video not found")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("How does 3two1 work?")
                    .font(Appearance().obTitle)
                    .multilineTextAlignment(.center)
                    .bold()
                    .padding()
                    .padding(.bottom, 30)

                VideoPlayer(player: player)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                
                Text("Make sure to unmute your device to hear the video audio.").font(Appearance().sectionTitle).padding(.top, 5)
                
                Button(action: {
                    if isPlaying {
                        player.pause()
                    } else {
                        player.play()
                    }
                    isPlaying.toggle()
                }) {
                    HStack {
                        Image(systemName: isPlaying ? "pause" : "play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            
                            .foregroundColor(.white)
                        Text(isPlaying ? "Pause" : "Play").foregroundStyle(.white)
                    }
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 40)
                    .background {
                            Capsule()
                            .fill(.black)
                                
                        }
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
