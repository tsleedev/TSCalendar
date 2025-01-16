//
//  CustomHeaderCalendarView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 1/10/25.
//

import SwiftUI
import TSCalendar

struct CustomHeaderCalendarView: View {
    @StateObject private var controller = CalendarController(
        config: TSCalendarConfig(
            showHeader: false
        )
    )
    @State private var showSettings = false
    @State private var refreshID = UUID()
    
    var body: some View {
        VStack {
            HStack {
                Text(controller.headerTitle)
                    .font(.system(size: 17))
                Spacer()
                Button(action: {
                    controller.config.heightStyle = controller.config.heightStyle.isFlexible ? .fixed(60) : .flexible
                    refreshID = UUID()
                }) {
                    Text(controller.config.heightStyle.isFlexible ? "Collapse" : "Expand")
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 16)
            TSCalendar(
                config: controller.config,
                delegate: controller,
                dataSource: controller
            )
            if !controller.config.heightStyle.isFlexible {
                Spacer()
            }
        }
        .id(refreshID)
        .navigationTitle("CustomHeaderCalendar")
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
    CustomHeaderCalendarView()
}
