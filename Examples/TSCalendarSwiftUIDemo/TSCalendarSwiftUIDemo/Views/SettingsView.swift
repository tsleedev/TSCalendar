//
//  SettingsView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/31/24.
//

import SwiftUI
import TSCalendar

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var controller: CalendarController
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Calendar Settings")) {
                    Picker("Display Mode", selection: $controller.displayMode) {
                        ForEach(TSCalendarDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.description)
                                .tag(mode)
                        }
                    }
                    
                    Picker("Start of Week", selection: $controller.startWeekDay) {
                        ForEach(TSCalendarStartWeekDay.allCases, id: \.self) { weekDay in
                            Text(weekDay.description)
                                .tag(weekDay)
                        }
                    }
                    
                    Picker("Scroll Direction", selection: $controller.scrollDirection) {
                        ForEach(TSCalendarScrollDirection.allCases, id: \.self) { direction in
                            Text(direction.description)
                                .tag(direction)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: closeButton)
        }
    }
    
    private var closeButton: some View {
        Button("Close") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    SettingsView(controller: CalendarController())
}
