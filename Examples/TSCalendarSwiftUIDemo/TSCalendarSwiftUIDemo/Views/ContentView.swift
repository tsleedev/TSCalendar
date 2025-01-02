//
//  ContentView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI
import TSCalendar

struct ContentView: View {
    @StateObject private var controller = CalendarController()
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                TSCalendar(
                    displayMode: controller.displayMode,
                    scrollDirection: controller.scrollDirection,
                    startWeekDay: controller.startWeekDay,
                    delegate: controller,
                    dataSource: controller
                )
            }
            .navigationBarItems(trailing: settingsButton)
            .sheet(isPresented: $showSettings) {
                SettingsView(controller: controller)
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showSettings = true
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}

#Preview {
    ContentView()
}
