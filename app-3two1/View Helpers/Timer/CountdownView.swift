//
//  CountdownView.swift
//  app-3two1
//
//  Created by Chantal Rohde on 25.01.24.
//
import SwiftUI
import CoreData
import Foundation
import AVFoundation

/** CONTAINS THE STRUCTURE FOR COUNTDOWN TIMER **/

struct CountdownSliderView: View {
    @ObservedObject var viewModel: TimerViewModel
   
    var notifHelper = NotificationHelper()

    //Audioplayer
    @State private var player: AVAudioPlayer?
    
    //Haptic Feedback
    @State private var hapticComplete = false
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var body: some View {
        ZStack {            
            VStack {
                ZStack {
                    Circle() // full circle
                        .stroke(colorThemeSelection.colorAccentPick)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 530 : 330, height: UIDevice.current.userInterfaceIdiom == .pad ? 530 : 330)
                        .overlay {
                            VStack {
                                HStack {
                                    Text("\(viewModel.formattedTime(viewModel.initialCountdown - viewModel.elapsedTime))")
                                        .font(Appearance().timerFont.bold())
                                        .offset(y: 40)
                                }
                                
                                Button(action: {
                                    
                                    // stop tracking
                                    if viewModel.isTimerRunning {
                                        
                                            viewModel.endTime = Date()
                                            viewModel.timer?.invalidate()
                                            viewModel.timer = nil
                                            viewModel.giveUpAlert.toggle()
                                            viewModel.stopTime = Date()
                                     }
                                        
                                     else {   // start tracking
                                         if(viewModel.selectionComplete){ // only if selection is complete
                                           
                                             // send notification
                                             notifHelper.sendTimerNotification(seconds:viewModel.initialCountdown)
                                             
                                             // set up timer
                                             viewModel.timeRemaining = Int(viewModel.initialCountdown)
                                             viewModel.startTime = Date()
                                             viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                                 if let startTime = viewModel.startTime {
                                                     viewModel.elapsedTime = Date().timeIntervalSince(startTime)
                                                     
                                                     // check when timer reaches 0
                                                     if viewModel.initialCountdown-viewModel.elapsedTime <= 0 {
                                                        
                                                         print("TIMER FINISHED")
                                                         viewModel.isTimerRunning = false
                                                         viewModel.endTime = Date()
                                                         viewModel.timer?.invalidate()
                                                         viewModel.timer = nil
                                                         self.playSound() // plays complete s
                                                         hapticComplete = true
                                                         viewModel.countdownFinishedAlert.toggle()
                                                     }
                                                 }
                                             }
                                             viewModel.isTimerRunning.toggle()
                                         }
                                         else { // trigger alert
                                             viewModel.noSelectionAlert.toggle()
                                         }
                                    }
                                   
                                })
                                {
                                    HStack { // adjust image based on timer being active or not
                                    Image(systemName: viewModel.isTimerRunning  ? "stop.fill" : "play.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 30)
                                        .foregroundColor(colorThemeSelection.colorAccentPick)

                                        Text(viewModel.isTimerRunning  ? "Stop" : "Start").font(fontSizeSelection.fontSizePick).foregroundStyle(colorThemeSelection.colorAccentPick)
                                }
                                    .padding([.top, .bottom], 10)
                                    .padding([.leading, .trailing], 40)
                                        .background {
                                            Capsule()
                                                .fill(colorThemeSelection.colorAccentPick.opacity(0.2))
                                                .stroke(colorThemeSelection.colorAccentPick)
                                        }
                                }
                                .padding()
                            }
                            .padding(.top, -20)
                        }
                    
                    Circle() // trimmable circle
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(colorThemeSelection.colorAccentPick,
                                style: StrokeStyle(lineWidth: 20.0, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                    
                    Circle() // indicate drag point
                        .fill(Color.white)
                        .shadow(radius: 3)
                        .frame(width: 21, height: 21)
                        .offset(y: -viewModel.ringDiameter / 1.8)
                        .rotationEffect(viewModel.rotationAngle)
                        .gesture( // change trimmed circle based on gesture angle
                            DragGesture(minimumDistance: 0.0)
                                .onChanged() { value in
                                    if !viewModel.isTimerRunning {
                                        viewModel.rotationAngle = viewModel.changeAngle(location: value.location)
                                    }
                                }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sensoryFeedback(.success, trigger: hapticComplete) // haptic feedback
        .alert("You haven't completed the task yet.", isPresented: $viewModel.giveUpAlert) {
            Button("Resume",action: {
                
                // resume the time track exactly where it stopped
                let resumeTime = Date()
                let pausedTime = resumeTime.timeIntervalSince(viewModel.stopTime!)
                viewModel.startTime = viewModel.startTime?.addingTimeInterval(pausedTime)
                
                // restart timer
                viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if let startTime = viewModel.startTime {
                        viewModel.elapsedTime = Date().timeIntervalSince(startTime)
                        
                        
                        if viewModel.initialCountdown-viewModel.elapsedTime <= 0 {
                            print("TIMER FINISHED")
                            viewModel.isTimerRunning = false
                            viewModel.endTime = Date()
                            viewModel.timer?.invalidate()
                            viewModel.timer = nil
                            viewModel.countdownFinishedAlert.toggle()
                        }
                    }
                }
 
            })
            Button("End Task",action: {
                    
                    // stop timer
                    viewModel.isTimerRunning.toggle()
                
                    // reset countdown
                    viewModel.resetCountdown()

                    // Save item to Core Data
                    viewModel.saveToggle.toggle()
            })
            
        }message: {
            Text("Are you sure you want to end this timer session?")
             
        }
        .alert("Task completed!", isPresented: $viewModel.countdownFinishedAlert) {
            
            Button("Close",action: {
                
                    // trigger to save item
                    viewModel.saveToggle.toggle()

                    // reset countdown
                    viewModel.resetCountdown()
            })
        }
       
    }
    
    // enables playing a sound when the timer is finished
    func playSound() {
        guard let path = Bundle.main.path(forResource: "complete", ofType:"wav") else {
                return }
            let url = URL(fileURLWithPath: path)

            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
    }
}

#Preview {
    ContentView()
}
