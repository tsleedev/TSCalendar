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
    
    var body: some View {
        VStack {
            HStack {
                Text(controller.headerTitle)
                    .font(.system(size: 17))
                Spacer()
                Button(action: {
                    controller.config.heightStyle = controller.isFlexible ? .fixed(60) : .flexible
                }) {
                    Text(controller.isFlexible ? "Collapse" : "Expand")
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 16)
            TSCalendar(
                config: controller.config,
                delegate: controller,
                dataSource: controller
            )
            if !controller.isFlexible {
                Spacer()
            }
        }
        .navigationTitle("CustomHeaderCalendarView")
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
