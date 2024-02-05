//
//  Appearance.swift
//  app-3two1
//
//  Created by Serin on 22.01.24.
//

import Foundation
import SwiftUI

struct Appearance {
    @AppStorage("fontSizeSelection") public var fontSizeSelection: FontSelection = .regular
    
    //for section titles in settings
    var sectionTitle: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: -4)
    }
    
    //for sheet titles in settings
    var sheetTitle: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: 3)
    }
    
    //Onboarding experience
    
    //Title
    var obTitle: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: 18)
    }
    
    //Text
    var obText: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: 10)
    }
    
    //Why's
    var whyButton: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: -3)
    }
    
    //Calendar
    var weekdayFont: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: -3)
    }
    
    //Projects View
    var taskViewProjectName: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: -5)
    }
    
    var taskViewTaskName: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: 3)
    }
    
    var addSheetTitle: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: 3)
    }
    
    //Progress View
    var statisticAnnotation: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: -5)
    }
    
    //Timer View
    var timerFont: Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: 40)
    }
    
    var timerTextSmall : Font {
        return .dynamicFont(fontSize: fontSizeSelection.fontSizePick, addition: -6)
    }
    
    
}

//DARK MODE
enum ThemeSelection: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    
    func theme(_ option: ColorScheme) -> Color {
        switch self {
        case .light:
            return .garfield
        case .dark:
            return .vampire
        }
    }
    
    //used to address the currently set display theme
    var themePick: ColorScheme? {
        switch self {
        case .light:
           // print("light")
            return .light
        case .dark:
          //  print("dark")
            return .dark
        }
    }
}

//COLOR ACCENT
enum ColorSelection: String, CaseIterable {
    case blue = "Blue"
    case red = "Red"
    case green = "Green"
    
    //used to address the currently set color accent
    var colorAccentPick: Color {
        switch self {
        case .blue:
          //  print("blue")
            return .blueTheme
        case .red:
          //  print("red")
            return .redTheme
        case .green:
           // print("green")
            return .greenTheme
        }
        
    }
}

//FONT
extension Font {
    //fixed sizes for the 3 options that the app offers
    static let smallSize = 14.0
    static let regularSize = 17.0
    static let largeSize = 20.0
    
    //these functions allow using the font size option in the "FONT" type context
    static func smallFont() -> Font {
        return system(size: self.smallSize)
    }

    static func regularFont() -> Font {
        return system(size: self.regularSize)
    }

    static func largeFont() -> Font {
        return system(size: self.largeSize)
    }
    
    //this function allows us to create custom font sizes that dynamically scale with the currently set global font size
    static func dynamicFont(fontSize: Font, addition: CGFloat = 0.0) -> Font {
        switch fontSize {
        case smallFont():
            return system(size: self.smallSize + addition)
        case regularFont():
            return system(size: self.regularSize + addition)
        case largeFont():
            return system(size: self.largeSize + addition)
        default:
            return system(size: self.regularSize + addition)
        }
    }
}

enum FontSelection: String, CaseIterable {
    case small = "Small"
    case regular = "Regular"
    case large = "Large"
    
    //used to address the currently set font size
    var fontSizePick: Font {
        switch self {
        case .small:
           // print("small font")
            return Font.smallFont()
        case .regular:
          //  print("regular font")
            return Font.regularFont()
        case .large:
          //  print("large font")
            return Font.largeFont()
        }
    }
}

#Preview {
    ContentView()
}
