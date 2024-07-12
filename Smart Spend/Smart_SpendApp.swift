//
//  Smart_SpendApp.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//

import SwiftUI

@main
struct Smart_SpendApp: App {
    @State private var dataController = DataController()
    //let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
