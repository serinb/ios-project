//
//  app_3two1App.swift
//  app-3two1
//
//  Created by Martin Zakrzewski on 17.12.23.
//

import SwiftUI

@main
struct app_3two1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
