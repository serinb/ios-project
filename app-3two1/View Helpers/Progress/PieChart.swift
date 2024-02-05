//
//  PieChart.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 25/01/2024.
//

import SwiftUI
import Charts

struct PieChart: View {
    var displayedItems: [Item]
    var isGroupedByProject: Bool
    var timeRangeView: String
        
    var body: some View {
        VStack {
            Chart {
                ForEach(displayedItems) { item in
                    // create a sector in the pie chart with different values depending on the toggle that groups data by project
                    SectorMark(
                        angle: .value(
                            isGroupedByProject ?
                            "project" : "task",
                            // convert time interval's seconds to hours
                            (item.timestampEnd?.timeIntervalSince(item.timestamp!) ?? 0.0) / 3600),
                        // if the data is not grouped by project, add lines between tasks to better see their proportions on the pie chart
                        angularInset: isGroupedByProject ? 0 : 2
                    )
                    .foregroundStyle(
                        // sort items by project name, so every task from one project has the same colour
                        by: .value(
                            "project", item.taskForTimestamp?.originProject?.name ?? "")
                    )
                    .annotation(position: .overlay) {
                        if !isGroupedByProject && ["Day", "Week"].contains(timeRangeView) {
                            VStack {
                                Text("\(item.taskForTimestamp?.name ?? "")")
                                    .font(Appearance().statisticAnnotation)
                                    .foregroundStyle(.white)
                                Text("\((item.timestampEnd?.timeIntervalSince(item.timestamp!) ?? 0.0) / 3600)h")
                                    .font(Appearance().statisticAnnotation)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
