//
//  TimerViewModel.swift
//  app-3two1
//
//  Created by Chantal Rohde on 23.01.24.
//

import Foundation
import CoreData
import SwiftUI


final class TimerViewModel:CoreDataModel, ObservableObject {
    
    // signalize to save an item
    @Published var saveToggle = false
    
    @Published var selectedGoal = 0
    @Published var goalOptions = [1,2,3,4,5,6,7,8,9,10,11,12]
  
    // item properties properties
    @Published var startTime: Date?
    @Published var endTime: Date?
    @AppStorage("Timer") var elapsedTime: TimeInterval = 0.0
    @Published var timer: Timer?
    
    // switch between stopwatch and countdown
    @Published var isToggleOn = false
    
   // properties provided by countdown view
    @Published var timeRemaining:Int = 0
    @Published var initialCountdown = 1500.0
    @Published var progress = 0.33
    @Published var rotationAngle = Angle(degrees: 120)
    
    // for early stop of countdown
    @Published var giveUpAlert:Bool = false
    
    // confirmation for stopwatch and finished countdown
    @Published var stopwatchConfirmationAlert:Bool = false
    @Published var countdownFinishedAlert:Bool = false
    
    // properties provided by stopwatch
    @Published var rotationAngle2 = Angle(degrees: 0)
    
    @Published var stopTime:Date?
    
    // event properties
    @Published var isTimerRunning = false
    @Published var isProjectSheetPresented = false
    @Published var isTaskSheetPresented = false
    @Published var isHistorySheetPresented = false
    @Published var noSelectionAlert = false
    
    // properties for progress bar
    @Published var showProgressSheet = false
    // number of desired tracks for the day
    @Published var trackingGoal = 0
    @Published var trackedTimes = 0
    @Published var percent: CGFloat = 0
    // shows if selection (project and task) is incomplete
    @Published var selectionComplete = false
    @Published var unfoldToggle = false
    var newHeight:CGFloat{
        return !unfoldToggle ? 150 : 250
    }

    let ringDiameter: Double = UIDevice.current.userInterfaceIdiom == .pad ? 475.0 : 300.0

   
    // reset countdown e.g. after toggle
    func resetCountdown(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Set a different progress value for iPad
            self.progress = 0.18
            self.rotationAngle = Angle(degrees: 65)
        } else {
            // Default progress value for other devices
            self.progress = 0.33
            self.rotationAngle = Angle(degrees: 120)
        }
        self.elapsedTime = 0
        self.initialCountdown = 1500.0
    }
    
    // reset stopwatch e.g. after toggle
    func resetStopwatch(){
        self.progress = 0
        self.rotationAngle = Angle(degrees: 0)
        self.elapsedTime = 0
    }

    // calculate slider position baed on the angle of the touch gesture
    func changeAngle(location: CGPoint) -> Angle {
        
        // Create a Vector for the location (reversing the y-coordinate system on iOS)
        let vector = CGVector(dx: location.x, dy: -location.y)
        
        // Calculate the angle of the vector
        let angleRadians = atan2(vector.dx, vector.dy)
        
        // Convert the angle to a range from 0 to 360 (rather than having negative angles)
        let positiveAngle = angleRadians < 0.0 ? angleRadians + (2.0 * .pi) : angleRadians
        
        // Update slider progress value based on angle
        self.progress = positiveAngle / (2.0 * .pi)
        
        // reduce angle to 2 decimal places for switch case
        let stringValue = (String(format: "%.2f", positiveAngle))
        

        if let doubleValue = Double(stringValue) {  // Successfully converted the string to a double
           
            // ASSIGN INITIAL COUNTDOWN TO ANGLE INTERVAL
            // maximum time (2 hours) : 7200 seconds, with time intervals of 5 minutes: / 300 seconds
            // -> 7200 : 300 = 24 sections needed
            
            // width of one section = (2*pi / 24) = 0.26 approximately
            
            switch doubleValue {
            case 0...0.1:
                self.initialCountdown = 60.0  // I added one additional section for 1 minute time track
            case 0.1...0.26:
                self.initialCountdown = 300.0
            case 0.27...0.52:
                self.initialCountdown = 600.0
            case 0.28...0.78:
                self.initialCountdown = 900.0
            case 0.79...1.04:
                self.initialCountdown = 1200.0
            case 1.05...1.3:
                self.initialCountdown = 1500.0
            case 1.06...1.57:
                self.initialCountdown = 1800.0
            case 1.58...1.83:
                self.initialCountdown = 2100.0
            case 1.84...2.09:
                self.initialCountdown = 2400.0
            case 2.10...2.35:
                self.initialCountdown = 2700.0
            case 2.36...2.61:
                self.initialCountdown = 3000.0
            case 2.62...2.87:
                self.initialCountdown = 3300.0
            case 2.88...3.14:
                self.initialCountdown = 3600.0
            case 3.15...3.40:
                self.initialCountdown = 3900.0
            case 3.41...3.66:
                self.initialCountdown = 4200.0
            case 3.67...3.92:
                self.initialCountdown = 4500.0
            case 3.91...4.18:
                self.initialCountdown = 4800.0
            case 4.19...4.45:
                self.initialCountdown = 5100.0
            case 4.46...4.71:
                self.initialCountdown = 5400.0
            case 4.72...4.97:
                self.initialCountdown = 5700.0
            case 4.98...5.23:
                self.initialCountdown = 6000.0
            case 5.24...5.49:
                self.initialCountdown = 6300.0
            case 5.50...5.75:
                self.initialCountdown = 6600.0
            case 5.76...6.02:
                self.initialCountdown = 6900.0
            case 6.03...6.28:
                self.initialCountdown = 7200.0
                
            default:
                break
            }
        } else {
            // Unable to convert the string to a double
            print("Invalid string format for conversion to double")
        }
  
        return Angle(radians: positiveAngle)
    }

    // formatted time for timer
    func formattedTime(_ timeInterval: TimeInterval?) -> String {
        guard let timeInterval = timeInterval else {
            return "00:00:00"
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    // get progress goal and tracks from core data
   func refreshProgress() {
        let width = UIScreen.main.bounds.width - 40
        print ("width: \(width)")
        
       if getGoal() != 0 {
           let percentageOfOne =  width / Double(getGoal())
           let limit = getTracks() >= getGoal() ? getGoal() : getTracks()
           percent =  percentageOfOne * Double(limit)
       }
       else {
           saveProgressToCoreData(goal: 0, tracks: 0)
           percent = 0
       }
    }
    
    // for testing purposes
    func fill() {
         let width = UIScreen.main.bounds.width - 40
         percent =  width
     }
     
    func resetPercent(){
         percent = 0 
     }

    
}



