//
//  CalendarView.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 21/12/2023.
//

import SwiftUI
import CoreData
import UserNotifications

struct CalendarView: View {
    //to address current display theme
    @Environment(\.colorScheme) public var currentScheme
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //to address the user's name
    @AppStorage("username") var username: String = ""
    
    // get the current date and use the @state property wrapper
    @State var dateSelected = Date()
    
    // variable needed to switch between the months and use the @state property wrapper
    @State var monthAdded = 0
    
    // array consisting of all the weekdays
    let weekdays = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    
    // user’s current calendar
    let calendar = Calendar.current
    
    //to address the current date
    let date = Date()
    
    //array of all the tasks on a certain day
    @State private var filteredTasks: [Task] = []
    
    //array of all the tasks on a certain day
    @State private var savedProjects: [Project] = []
    
    //array of all the timestamps
    @State private var filteredItems: [Item] = []
    
    //checker
    @State private var dailyItems: [Item] = []
    
    // next Item for notification
    @State private var nextItem:Item? = nil
    
    //access to core data functions
    private var dataModel = CoreDataModel()
    
    //Variable determines if the Add Timestamp(/item) sheet is presented
    @State public var itemSheetOpen = false
    
    var body: some View {
        VStack(spacing:4){
            
            //define the month switcher
            HStack{
                
                Spacer()
                
                // Button to go back a year
                Button( action: {monthAdded -= 12}, label: {
                    Image(systemName: "chevron.left.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 15)
                    
                })
                
                Spacer()
                
                // Button to go back a month
                Button( action: {monthAdded -= 1}, label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 15)
                    
                })
                
                Spacer()
                
                // Show the selected Month and the year
                Text(dateSelected.monthYear())
                    .font(fontSizeSelection.fontSizePick)
                    .bold()
                    
                
                Spacer()
                
                // Button to go forward a month
                Button(action: {monthAdded += 1}, label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 15)
                    
                })
                
                Spacer()
                
                // Button to go forward a year
                Button(action: {monthAdded += 12}, label: {
                    Image(systemName: "chevron.right.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 15)
                    
                })
                
                Spacer()
            }
            .frame(width: 350, height: 50)
            .cornerRadius(25)
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 25)
            
            // days of the week
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .bold()
                        .font(Appearance().weekdayFont)
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 15)

            // Grid of the Days of the month
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5){
                ForEach(sortDates()) { value in
                    if  value.day == 0 {
                        Text("")
                    } else {
                        DayView(day: value.date, selectedDate: $dateSelected)
                            .font(fontSizeSelection.fontSizePick)
                            .frame(width: 32, height: 40)
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 15)
            
            // Header for the lists of all tasks on a selected day
            HStack(alignment: .center){
                Text(dateSelected.formatted(.dateTime.weekday(.wide).day().month().year()))
                    .bold()
                    .font(fontSizeSelection.fontSizePick)
                    .foregroundStyle(Color.accentColor)
                    .padding([.top, .leading, .bottom], 10)
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        Rectangle()
                            .fill(Color.accentColor.opacity(0.2))
                    )
                Spacer()
                
                // Button to add an Item
                Button("", systemImage: "plus") {
                    itemSheetOpen.toggle()
                }
                .sheet(isPresented: $itemSheetOpen, onDismiss: fetchSavedItems, content: {
                    if savedProjects == []{
                        // For the case that there are no projects saved
                        Text("Hey \(username), \n Seems like you forgot to save a project. \n Please add a project to continue.")
                            .multilineTextAlignment(.center)
                            .bold()
                            .presentationDetents([.fraction(0.6), .large])
                            .presentationDragIndicator(.visible)
                    } else if filteredTasks == []{
                        // For the case that there are no tasks saved
                        Text("Hey \(username), \n Seems like you forgot to save a task.  \n Please add a task to continue.")
                            .multilineTextAlignment(.center)
                            .bold()
                            .presentationDetents([.fraction(0.6), .large])
                            .presentationDragIndicator(.visible)
                    }  else{
                        // Normal case when there is atleast a project or task there
                        if let selectedProject = savedProjects.first, let selectedTask = filteredTasks.first {
                            AddItem(itemSheetOpen: $itemSheetOpen, savedProjects: $savedProjects, savedTasks: $filteredTasks, selectedProject: selectedProject, selectedTask: selectedTask)
                                .presentationDetents([.fraction(0.6), .large])
                                .presentationDragIndicator(.visible)
                        }
                    }
                    
                })
                .padding([.top, .bottom, .trailing], 10.0)
            }
            .frame(maxWidth: .infinity)
            .background(Color.accentColor.opacity(0.2))
            .clipShape(
                    .rect(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )
            
            // Show all the tasks that occured in the day
            
                if dailyItems == []{
                    // For the case that there are no items for a selected date
                    VStack {
                        Text ("No events for today").bold()
                            .foregroundStyle(Color.accentColor)
                    }.frame( maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.accentColor.opacity(0.2))
                    
                }else{
                    VStack {
                        // Normal case
                        List {
                            Section {
                                ForEach(filteredItems, id: \.self) { item in
                                    if let timestamp = item.timestamp, timestamp.isSameDay(as: dateSelected) {
                                        VStack {
                                            PlannerItems(savedProjects: $savedProjects, filteredTasks: $filteredTasks, givenItem: item, filteredItems: $filteredItems)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteSavedItem)
                            }

                        }
                        .scrollContentBackground(.hidden)
                        .listSectionSpacing(.compact)
                        .listStyle(.insetGrouped)
                        .background(Color.accentColor.opacity(0.2))
                        .scrollContentBackground(.hidden)
                    }
                }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment.topLeading)
        .onChange(of: monthAdded) {
            //when month changes, change the view
            dateSelected = selectMonth()
        }
        .onAppear{
            //initialise all lists on appear
            self.fetchSavedTasks()
            filteredItems = dataModel.fetchSavedItems()
            savedProjects = dataModel.fetchSavedProjects()
            filteredItems = sortItems(as: filteredItems, as: dateSelected)
            nextItem = filteredItems.first
            setNotification(as: nextItem?.timestamp ?? Date().addingTimeInterval(-31536000))
            dailyItems  = filteredItems
        }
        .onChange(of: dateSelected){
            //if date changes initialise
            self.fetchSavedTasks()
            filteredItems = dataModel.fetchSavedItems()
            savedProjects = dataModel.fetchSavedProjects()
            filteredItems = sortItems(as: filteredItems, as: dateSelected)
            nextItem = filteredItems.first
            setNotification(as: nextItem?.timestamp ?? Date().addingTimeInterval(-31536000))
            dailyItems  = filteredItems
        }
        .onChange(of: filteredItems){
            // if itemslist changes initialise
            self.fetchSavedTasks()
            filteredItems = dataModel.fetchSavedItems()
            savedProjects = dataModel.fetchSavedProjects()
            filteredItems = sortItems(as: filteredItems, as: dateSelected)
            nextItem = filteredItems.first
            setNotification(as: nextItem?.timestamp ?? Date().addingTimeInterval(-31536000))
            dailyItems  = filteredItems
        }
    }
    
    // sort Items based on the chronology of events on a day
    func sortItems(as filteredItems: [Item],  as selectedDate: Date) -> [Item]{
        let dailyItems = filteredItems.filter { item in
            return item.timestamp?.isSameDay(as: selectedDate) ?? false
        }
        
        return dailyItems.sorted{ $0.timestamp! < $1.timestamp!}
    }
    
    // notification of the next task to be done 30 minutes prior
    func setNotification(as timestamp: Date) {
       
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["eventReminder"])

            // Schedule a new notification with updated information
            let content = UNMutableNotificationContent()
            content.title = "Hey " + username + "!"
            content.body = "Don't forget about your task at \(notificationFormatter(from: timestamp))."
            content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: (timestamp.addingTimeInterval(-1800)))
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(identifier: "eventReminder", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling updated notification: \(error)")
                }
            }
       
    }

    // function to delete an Item
    func deleteItem(_ itemToDelete:Item) {
        // get context
        let context = PersistenceController.shared.container.viewContext
        
        // delete item
        context.delete(itemToDelete)
        
        // Save context after deletion
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
    }
    
    // function to get all the saved tasks
    func fetchSavedTasks() {
        let context = PersistenceController.shared.container.viewContext
        do {
            self.filteredTasks = try context.fetch(Task.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    // function to get all the saved items
    private func fetchSavedItems() {
        let context = PersistenceController.shared.container.viewContext
        
        do {
            // Fetch items from Core Data
            self.filteredItems = try context.fetch(Item.fetchRequest())
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }
    
    // function to delete saved Item at a position
    private func deleteSavedItem(at offsets: IndexSet) {
        let context = PersistenceController.shared.container.viewContext
        // Delete item from Core Data model
        for index in offsets {
            let itemToDelete = filteredItems[index]
            context.delete(itemToDelete)
        }
        
        // Save context after deletion
        do {
            try context.save()
        } catch {
            print("Error saving after deletion: \(error)")
        }
        filteredItems = dataModel.fetchSavedItems()
    }
    
    //returns an array of datesMonth objects
    func sortDates() -> [DatesMonth] {
        let actualMonth = selectMonth()
        let dates = actualMonth.datesOfMonth().map {
            DatesMonth(day: Calendar.current.component(.day, from: $0), date: $0)
        }
        let firstWeekday = (Calendar.current.component(.weekday, from: dates.first?.date ?? Date()) + 5) % 7 + 1
        let emptyDays = Array(repeating: DatesMonth(day: 0, date: Date()), count: firstWeekday - 1)
        return emptyDays + dates
    }
    
    //add the months based on the int variable addedMonth
    func selectMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: monthAdded, to: Date()) ?? Date()
    }
    
    // notification formatter for the time in notifications
    func notificationFormatter(from date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }

    // represent a date within a month
    struct DatesMonth: Identifiable{
        let id = UUID()
        var day: Int
        var date: Date
    }
}



extension Date {
    //date formatter for the header
    func monthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL YYYY"
        return formatter.string(from: self)
    }
    
    //generates an array of Date objects representing all the days in the month
    func datesOfMonth() -> [Date] {
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: self)
            let currentYear = calendar.component(.year, from: self)
            
            let startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
            let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
            
            var dates: [Date] = []
            var currentDate = startDate
            
            while currentDate <= endDate {
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            return dates
        }
}
    // create the picker for the day grid
    struct DayView: View {
        let day: Date
        @Binding var selectedDate: Date
        //to address current font size
        @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
        
    
        var body: some View {
            Text("\(day.day)")
                .font(fontSizeSelection.fontSizePick)
                .frame(maxWidth: .infinity, minHeight: 40)
                .foregroundColor(day.isSameDay(as: selectedDate) ? .standardTheme : .primary)
                .background(day.isSameDay(as: selectedDate) ? Color.accentColor : Color.clear)
                .clipShape(Circle())
                .onTapGesture {
                    selectedDate = day
                }
        }
    }

extension Date {
    // return the day of the month as a string
    var day: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    //check if the dates are same
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

#Preview {
    ContentView()
    //CalendarView()
}
