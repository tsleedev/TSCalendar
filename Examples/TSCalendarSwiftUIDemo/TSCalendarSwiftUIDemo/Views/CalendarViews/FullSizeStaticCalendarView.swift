//
//  FullSizeStaticCalendarView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 1/17/25.
//

import SwiftUI
import TSCalendar

struct FullSizeStaticCalendarView: View {
    @StateObject private var controller = CalendarController(
        config: TSCalendarConfig(
            autoSelect: false,
            isPagingEnabled: false,
            scrollDirection: .vertical
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
        .navigationTitle("FullSizeStaticCalendar")
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
    FullSizeStaticCalendarView()
}
