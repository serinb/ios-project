//
//  DateButtonsGroup.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 25/01/2024.
//

import SwiftUI

struct DateButtonsGroup: View {
    @Binding var displayedDate: Date
    var timeRangeView: String
    
    //to address current font size
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    
    var body: some View {
        HStack {
            // go back button
            Button {
                // change the displayed date according to a chosen time range
                switch timeRangeView {
                case "Day":
                    displayedDate = addOrSubtractDay(day: -1)
                    break
                case "Week":
                    displayedDate = addOrSubtractWeek(week: -1)
                    break
                case "Month":
                    displayedDate = addOrSubtractMonth(month: -1)
                    break
                case "Year":
                    displayedDate = addOrSubtractYear(year: -1)
                    break
                default:
                    break
                }
            }
        label: {
            Image(systemName: "chevron.left")
                .padding(.trailing, 20)
        }
        .buttonStyle(.borderless)
            
            // current date button
            Button {
                // if the button is tapped, go to the today's date
                displayedDate = Date.now
            }
        label: {
            Text(
                displayedDate,
                format: .dateTime.day().month().year()
            )
            .font(fontSizeSelection.fontSizePick)
            
        }
        .buttonStyle(.borderless)
            
            // go forward button
            Button {
                // change the displayed date according to a chosen time range
                switch timeRangeView {
                case "Day":
                    displayedDate = addOrSubtractDay(day: 1)
                    break
                case "Week":
                    displayedDate = addOrSubtractWeek(week: 1)
                    break
                case "Month":
                    displayedDate = addOrSubtractMonth(month: 1)
                    break
                case "Year":
                    displayedDate = addOrSubtractYear(year: 1)
                    break
                default:
                    break
                }
            }
        label: {
            Image(systemName: "chevron.right")
                .padding(.leading, 20)
        }
        .buttonStyle(.borderless)
        }
    }
    // add the specified number of days to the displayedDate
    func addOrSubtractDay(day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: displayedDate)!
    }
    
    // add the specified number of weeks to the displayedDate
    func addOrSubtractWeek(week: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: week, to: displayedDate)!
    }
    
    // add the specified number of months to the displayedDate
    func addOrSubtractMonth(month: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: displayedDate)!
    }
    
    // add the specified number of years to the displayedDate
    func addOrSubtractYear(year: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: year, to: displayedDate)!
    }
}

#Preview {
    ContentView()
}
