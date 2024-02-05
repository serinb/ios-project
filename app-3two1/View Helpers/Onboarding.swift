//
//  Onboarding.swift
//  app-3two1
//
//  Created by Serin on 16.01.24.
//

import Foundation
import SwiftUI

struct OBSheet: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var text: String
    var sheetnum: Int
    
    static var samplePage = OBSheet(title: "Title", text: "blabla", sheetnum: 0)
    
    static var samplePages: [OBSheet] = [
        OBSheet(title: "Welcome to 3two1!", text: "Master your studies and beat procrastination in\n 3-2-1!", sheetnum: 0),
        OBSheet(title: "What's your name?\n", text: "", sheetnum: 1),
        //FIXME: add a WHY?? pop up
        OBSheet(title: "Nice to meet you\n USERNAME", text: "Is it okay, if 3two1 sends you notifications?\n", sheetnum: 2),
        OBSheet(title: "How does 3two1 work?", text: "", sheetnum: 3)


    ]
}
    

    

