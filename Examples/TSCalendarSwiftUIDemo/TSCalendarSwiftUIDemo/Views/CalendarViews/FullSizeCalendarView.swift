//
//  FullSizeCalendarView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 1/7/25.
//

import SwiftUI
import TSCalendar

struct FullSizeCalendarView: View {
    @StateObject private var controller = CalendarController(
        config: TSCalendarConfig(
            scrollDirection: .vertical,
            showWeekNumber: true
        )
    )
    @State private var showSettings = false
    
    var body: some View {
        VStack {
            TSCalendar(
                config: controller.config,
                delegate: controller,
                dataSource: controller
            )
        }
        .navigationTitle("FullSizeCalendar")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: settingsButton)
        .sheet(isPresented: $showSettings) {
            SettingsView(controller: controller)
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
    FullSizeCalendarView()
}
