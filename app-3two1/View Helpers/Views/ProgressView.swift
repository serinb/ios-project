//
//  ProgressView.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 21/12/2023.
//

import SwiftUI

struct ProgressView: View {
    @State private var plotType = 0                     // 0 = bar plot, 1 = pie chart
    
    var timeRanges = ["Day", "Week", "Month", "Year"]   // possible time ranges to group by
    @State private var timeRangeView = "Day"            // chosen time range to group by
    
    @State private var isGroupedByProject = false
    
    @State private var displayedDate = Date.now         // date that is currently displayed
    
    @State private var selectedTags: Set<Tag> = []
    
    private var dataModel = CoreDataModel()             // Core Data model functions
    @State var savedItems: [Item] = []                  // all of the items fetched from Core Data
    @State var savedTags: [Tag] = []                    // all of the tags fetched from Core Data
    @State private var displayedItems: [Item] = []      // subset of items that is currently displayed on the plot
    
    @State private var isMoreOptionsSheetOpen = false         // indicates if the sheet for options is open
    
    //to address the current display theme
    @AppStorage("displayTheme") public var displayTheme: ThemeSelection = .light
    //to address current color accent
    @AppStorage("colorThemeSelection") var colorThemeSelection: ColorSelection = .blue
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    var body: some View {
            VStack {
                VStack {
                    // --------- TIME RANGE PICKER ---------
                    Picker("Time range", selection: $timeRangeView) {
                        ForEach(timeRanges, id: \.self) {
                            Text($0)
                                .font(fontSizeSelection.fontSizePick)
                        }
                    }
                    .onChange(of: timeRangeView, filterData)
                    .pickerStyle(.segmented)
                    .padding()
                    .padding(.bottom, 10)
                    
                    
                    // -------- DATE BUTTONS GROUP ---------
                    DateButtonsGroup(displayedDate: $displayedDate, timeRangeView: timeRangeView)
                        .onChange(of: displayedDate, filterData)
                        .padding(.bottom, 20)
                        
                }
                 
                VStack {
                    HStack {
                        // --------- PLOT TYPE PICKER --------
                        Picker("Plot type", selection: $plotType) {
                            Image(systemName: "chart.bar")
                                .foregroundStyle(colorThemeSelection.colorAccentPick)
                                .tag(0)
                                
                            Image(systemName: "chart.pie")
                                .foregroundStyle(colorThemeSelection.colorAccentPick)
                                .tag(1)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                        
                        Spacer()
                        
                        // --------- FILTERING OPTIONS --------
                        Button {
                            isMoreOptionsSheetOpen.toggle()
                        } label: {
                            Image(systemName: "ellipsis")
                                .padding([.top, .bottom], 10)
                                .padding([.leading, .trailing], 3)
                                .foregroundStyle(colorThemeSelection.colorAccentPick)
                                .rotationEffect(.degrees(-90))
                                .background {
                                    RoundedRectangle(cornerRadius:5)
                                        .fill(Color.clear)
                                        .stroke(colorThemeSelection.colorAccentPick)
                                }
                        }
                        .sheet(isPresented: $isMoreOptionsSheetOpen, content: {
                            VStack {
                                // -------- GROUP BY PROJECT TOGGLE --------
                                Toggle(isOn: $isGroupedByProject) {
                                    Text("Group by Project")
                                        .font(fontSizeSelection.fontSizePick)
                                        .frame(
                                            alignment: .leading
                                        )
                                }
                                .padding()
                                
                                // -------- TAG PICKER --------
                                HStack {
                                    Text("Filter by Tag")
                                        .font(fontSizeSelection.fontSizePick)
                                    Spacer()
                                    Menu {
                                        Button("All Tags") {
                                            selectedTags.removeAll()
                                        }
                                        Divider()
                                        ForEach(savedTags, id: \.self) { tag in
                                            Button(action: {
                                                if selectedTags.contains(tag) {
                                                    selectedTags.remove(tag)
                                                } else {
                                                    selectedTags.insert(tag)
                                                }
                                            }) {
                                                HStack {
                                                    Text(tag.name ?? "")
                                                        .font(fontSizeSelection.fontSizePick)
                                                    if selectedTags.contains(tag) {
                                                        Spacer()
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "line.3.horizontal.decrease.circle")
                                            .imageScale(.large)
                                    }
                                    .onChange(of: selectedTags, filterData)
                                }
                                .padding()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.standardTheme)
                            .environment(\.colorScheme, displayTheme.themePick!)
                            .presentationDetents([.fraction(0.2), .medium])
                            .presentationDragIndicator(.visible)
                        })
                    }
                    
                    
                    // -------- BAR PLOT --------
                    if plotType == 0 {  // is bar plot
                        BarPlot(displayedItems: displayedItems, isGroupedByProject: isGroupedByProject)
                            .padding()
                    }
                    
                    // -------- PIE CHART --------
                    else { // is pie chart
                        PieChart(displayedItems: displayedItems, isGroupedByProject: isGroupedByProject, timeRangeView: timeRangeView)
                            .padding()
                    }
                }
                .padding()
                .background(.whiteBlack)
                .clipShape(
                    .rect(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20
                    )
                )
            }
            .background(colorThemeSelection.colorAccentPick.opacity(0.2))
            .onAppear {
                // fetch saved items from Core Data
                savedItems = dataModel.fetchSavedItems()
                // fetch saved tags from Core Data
                savedTags = dataModel.fetchSavedTags()
                // get data only for today's date
                filterData()
            }
        
    }
    
    // get data to display on the plot
    func filterData() {
        // first, filter for selected tags
        if !selectedTags.isEmpty {
            displayedItems = savedItems.filter { item in
                if let taskTags = item.taskForTimestamp?.assignedTags {
                    let taskTagSet = Set(taskTags.compactMap { $0 as? Tag })
                    return !selectedTags.isDisjoint(with: taskTagSet)
                }
                return false
            }
        } else {
            displayedItems = savedItems
        }
        
        //second, filter for a chosen time range
        switch timeRangeView {
            // filter data for if the chosen time range is day
        case "Day":
            // filter all data
            displayedItems = displayedItems.filter { item in
                if let itemTimestamp = item.timestamp {
                    // compare the current item timestamp's day is the same with the date to be displayed
                    if Calendar.current.component(.day, from: itemTimestamp) == Calendar.current.component(.day, from: displayedDate) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
            break
            // week
        case "Week":
            // filter all data
            displayedItems = displayedItems.filter { item in
                if let itemTimestamp = item.timestamp {
                    // compare the current item timestamp's week is the same with the date to be displayed
                    if Calendar.current.component(.weekOfYear, from: itemTimestamp) == Calendar.current.component(.weekOfYear, from: displayedDate) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
            break
            // month
        case "Month":
            // filter all data
            displayedItems = displayedItems.filter { item in
                if let itemTimestamp = item.timestamp {
                    // compare the current item timestamp's month is the same with the date to be displayed
                    if Calendar.current.component(.month, from: itemTimestamp) == Calendar.current.component(.month, from: displayedDate) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
            break
        default:
            break
        }
        // at the end, filter all data by year! for Day/Week/Month/Year
        displayedItems = displayedItems.filter { item in
            if let itemTimestamp = item.timestamp {
                // compare the current item timestamp's year is the same with the date to be displayed
                if Calendar.current.component(.year, from: itemTimestamp) == Calendar.current.component(.year, from: displayedDate) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
    }
}

#Preview {
    ContentView()
}
