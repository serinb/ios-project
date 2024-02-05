//
//  Notifications.swift
//  app-3two1
//
//  Created by Serin on 22.01.24.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationHelper {
    //to address the user's name
    @AppStorage("username") var username: String = ""
    
    //for asking the user about allowing/disallowing Notification Permissions
    func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            success, error in
            if success {
                print("Notifications activated")
                
            } else if (error != nil) {
                print(error!)
            }
        }
    }
    
    /*
    //Function for sending notification about upcoming tasks in the planner
    func sendCalendarNotification() {
        //object for defining notification content
        let notifContent = UNMutableNotificationContent()
        //needed to specify the exact time and date of the notification
        var dateEvent = DateComponents()
        
        dateEvent.hour = 13
        dateEvent.minute = 25
        dateEvent.day = 8
        dateEvent.month = 1
        dateEvent.year = 2025
        
        //notification body and alert sound
        notifContent.title = "Hey " + username + "!"
        notifContent.body = "Don't forget to check your upcoming tasks for tomorrow."
        notifContent.sound = UNNotificationSound.default
        
        //initialize notification trigger, define that it should not be repeated
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: dateEvent, repeats: false)
        //create a notification request
        let notifRequest = UNNotificationRequest(identifier: "CalendarNotification", content: notifContent, trigger: notifTrigger)
        //send notification
        UNUserNotificationCenter.current().add(notifRequest)
    }
    */
    
    //Function for sending notification about when the timer ends
    func sendTimerNotification(seconds: Double) {
        print("send notification")
        //object for defining notification content
        let notifContent = UNMutableNotificationContent()
        
        //notification body and alert sound
        notifContent.title = "Hey " + username + "!"
        notifContent.body = "Your timer is up. You can move on to the next planned task now!"
        notifContent.sound = UNNotificationSound.default

        let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        //create a notification request
        let notifRequest = UNNotificationRequest(identifier: "TimerNotification", content: notifContent, trigger: notifTrigger)
        //send notification
        UNUserNotificationCenter.current().add(notifRequest)

    }
    
    // Function for sending a daily reminder about not forgetting planned tasks for the day
    // everyday at 8am
    func sendDailyNotfication() {
        //object for defining notification content
        let notifContent = UNMutableNotificationContent()
        //needed to specify the exact time and date of the notification
        var dailyTime = DateComponents()
        dailyTime.hour = 8
        dailyTime.minute = 0
        
        //notification body and alert sound
        notifContent.title = "Rise and Shine " + username + "!"
        notifContent.body = "Don't forget to work on your tasks planned for today."
        notifContent.sound = UNNotificationSound.default
        
        //initialize notification trigger, define that it should not be repeated
        let notifTrigger = UNCalendarNotificationTrigger(dateMatching: dailyTime, repeats: true)
        //create a notification request
        let notifRequest = UNNotificationRequest(identifier: "DailyNotification", content: notifContent, trigger: notifTrigger)
        //send notification
        UNUserNotificationCenter.current().add(notifRequest)
    }
    
    
    //this is only for testing reasons, it sends a notification after 5s
    func sendTestingNotification(type: String, timeIntervall: Double = 10, title: String, message: String) {
        let notifAppear = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervall, repeats: false)

        let notifContent = UNMutableNotificationContent()
        notifContent.title = title
        notifContent.body = message
        notifContent.sound = UNNotificationSound.default

        
        let request = UNNotificationRequest(identifier: "TestNotification", content: notifContent, trigger: notifAppear)
        
        UNUserNotificationCenter.current().add(request)
        
    }
}
