//
//  MainView.swift
//  Smart Spend
//
//  Created by Edward Jermyn on 09/05/2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem{
                    Label("Home", systemImage: "house.fill")
                }
            OutgoingView()
                .tabItem {
                    Label("Expenses", systemImage: "creditcard.fill")
                }
            IncomingView()
                .tabItem {
                    Label("Income", systemImage: "dollarsign.circle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}


#Preview {
    MainView()
}
