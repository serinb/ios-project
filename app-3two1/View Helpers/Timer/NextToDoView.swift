//
//  TodaysTaskView.swift
//  app-3two1
//
//  Created by Chantal Rohde on 25.01.24.
//

import SwiftUI
import CoreData
import Foundation


// NEXT TO-DO VIEW
struct NextTodoView: View {
    
    @ObservedObject var viewModel: TimerViewModel
    
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    // .font(fontSizeSelection.fontSizePick)
    
    var body: some View {
        
        ZStack(alignment:.top) {
            
            if let upcomingItem = getUpcomingItem(){

            VStack(){
                    Text("your upcoming to do:")
                    .italic()
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                    
                    // task name
                    Text(upcomingItem.taskForTimestamp!.name!)
                    .bold()
                    .font(.system(size: 30))
                
                    // project name
                    Text("(\(upcomingItem.taskForTimestamp!.originProject!.name!))")
                    .padding(.bottom)
   
                    // duration
                    var duration = calculateDuration(firstDate:upcomingItem.timestampEnd!,secondDate:upcomingItem.timestamp!)
                    Text("\(duration) Minute(s)")
                    .bold()
                    .font(.system(size: 30))
                    .padding(.bottom)

                    // Get the current calendar
                    let calendar = Calendar.current

                    // Extract hour and minute components from the date
                    let components = calendar.dateComponents([.hour, .minute], from: upcomingItem.timestamp!)

                    // Access the hour and minute values
                    if let hour = components.hour, let minute = components.minute {
                        Text("beginning from: \(hour):\(minute)")
                    } else {
                        Text("Failed to extract hour and minute components from the date.")
                    }
                }
            }
        }
    }
    
    // calculate duration in minutes when 2 dates are given
    func calculateDuration(firstDate:Date, secondDate:Date) -> Int {
        let calendar = Calendar.current
        
        // Calculate the time interval in seconds
        let timeIntervalInSeconds = firstDate.timeIntervalSince(secondDate)

        // Convert the time interval to minutes
        let timeIntervalInMinutes = Int(timeIntervalInSeconds / 60)
        
        return timeIntervalInMinutes
    }
    
    // get the next item that is not in the past -> get upcoming/active event
    func getUpcomingItem () -> Item? {
        
        let items = viewModel.fetchSavedItems()
        let currentDate = Date()

        // Filter out any items with timestampEnd property in the past
        var itemsInQuestion = items.filter { item in
            return item.timestampEnd ?? Date.distantPast > currentDate
        }

        // Sort the remaining dates in ascending order
        itemsInQuestion = itemsInQuestion.sorted{ $0.timestamp! < $1.timestamp!}
        
        // Take the first date from the sorted list (nearest future date)
        var nextItem = itemsInQuestion.first
        
        return nextItem
    }
}
