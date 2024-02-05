//
//  StopwatchView.swift
//  app-3two1
//
//  Created by Chantal Rohde on 25.01.24.
//

import Foundation
import SwiftUI
import CoreData

/** CONTAINS THE STRUCTURE FOR STOPWATCH TIMER**/

struct StopwatchView: View {
    
    // provides required properties and methods
    @ObservedObject var viewModel: TimerViewModel
    
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue

    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    Circle() // full circle
                        .stroke(colorThemeSelection.colorAccentPick)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 530 : 330, height: UIDevice.current.userInterfaceIdiom == .pad ? 530 : 330)
                        .overlay() {
                            VStack { // elapsed time
                                Text("\(viewModel.formattedTime(viewModel.elapsedTime))")
                                    .font(Appearance().timerFont.bold())
                                    .offset(y: 40)
                                
                                // start / stop button
                                Button(action: {

                                    if (viewModel.isTimerRunning) { // stop tracking
                                        
                                        // save end date, stop and reset timer
                                        viewModel.stopTime = Date()
                                        viewModel.endTime = Date()
                                        viewModel.timer?.invalidate()
                                        viewModel.timer = nil
                                        
                                        // send confirmation
                                        viewModel.stopwatchConfirmationAlert.toggle()
                                        
                                    } else { // start tracking
                                        
                                        if(viewModel.selectionComplete){  // start only if selection is complete
                                           
                                            // set start date, initialize timer
                                            viewModel.startTime = Date()
                                            viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                                if let startTime = viewModel.startTime {
                                                    
                                                    // calculate interval between start date and now
                                                    viewModel.elapsedTime = Date().timeIntervalSince(startTime)
                                                }
                                            }
                                            // set timer to running
                                            viewModel.isTimerRunning.toggle()
                                            
                                        } else { // send alert
                                            viewModel.noSelectionAlert.toggle()
                                        }
                                    }
                                    
                                }) {
                                    HStack { // adjust image based on if timer is running or not
                                        Image(systemName: viewModel.isTimerRunning  ? "stop.fill" : "play.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 30)
                                            .foregroundColor(colorThemeSelection.colorAccentPick)
                                        
                                        
                                        Text(viewModel.isTimerRunning ? "Stop" : "Start").foregroundStyle(colorThemeSelection.colorAccentPick)
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
                    
                    Circle() // trimmed circle increasing every second
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(colorThemeSelection.colorAccentPick,
                                style: StrokeStyle(lineWidth: 20.0, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
        }
        
        // stopwatch notification
        .alert("Did you complete your task?", isPresented: $viewModel.stopwatchConfirmationAlert) {
            Button("Resume",action: {
                
                // resume the time track exactly where it stopped by adding "paused time" to start time
                let resumeTime = Date()
                let pausedTime = resumeTime.timeIntervalSince(viewModel.stopTime!)
                viewModel.startTime = viewModel.startTime?.addingTimeInterval(pausedTime)
                
                // restart timer
                viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    if let startTime = viewModel.startTime {
                        viewModel.elapsedTime = Date().timeIntervalSince(startTime)
                    }
                }
 
            })
            Button("End Task",action: {
                    
                    // stop timer
                    viewModel.isTimerRunning.toggle()
                    
                    // reset timer
                    viewModel.resetStopwatch()
        
                    // Save item to Core Data
                    viewModel.saveToggle.toggle()
            })
            
        }message: {
            Text("Are you sure you want to end this timer session?")
             
        }
        
        .onChange(of: viewModel.elapsedTime){ // adjust trimmed circle based on elapsed time
            if viewModel.progress >= 1 { viewModel.progress = 0} else {viewModel.progress +=  1/60 }
            print("\(viewModel.progress)")
        }
 
    }
}

#Preview {
    ContentView()
}

