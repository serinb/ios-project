//
//  BarPlot.swift
//  app-3two1
//
//  Created by Aleksandra Kukawka on 25/01/2024.
//

import SwiftUI
import Charts

struct BarPlot: View {
    var displayedItems: [Item]
    var isGroupedByProject: Bool
    
    var body: some View {
        Chart {
            ForEach(displayedItems) { item in
                // create a bar with different x value depending on the toggle that groups data by project
                BarMark(
                    x: .value(
                        isGroupedByProject ? "project" : "task",
                        (isGroupedByProject ?
                         item.taskForTimestamp?.originProject?.name :
                            item.taskForTimestamp?.name) ?? ""
                    ),
                    y: .value(
                        "time",
                        // convert time interval's seconds to hours
                        (item.timestampEnd?.timeIntervalSince(item.timestamp!) ?? 0.0) / 3600)
                )
                .foregroundStyle(
                    // sort items by project name, so every task from one project has the same colour
                    by: .value(
                        "project",
                        item.taskForTimestamp?.originProject?.name ?? ""
                    )
                )
            }
        }
        // add a y-axis label
        .chartYAxisLabel("Time (hours)")
        // scrollable plot
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 5)
    }
}
