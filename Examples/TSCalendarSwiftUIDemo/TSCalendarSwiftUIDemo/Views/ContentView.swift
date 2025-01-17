//
//  ContentView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: FullSizeCalendarView()
                ) {
                    Text("FullSizeCalendar")
                }
                NavigationLink(
                    destination: FullSizeStaticCalendarView()
                ) {
                    Text("FullSizeStaticCalendar")
                }
                NavigationLink(
                    destination: FixedWeekHeightCalendarView()
                ) {
                    Text("FixedWeekHeightCalendar")
                }
                NavigationLink(
                    destination: FixedWeekHeightStaticCalendarView()
                ) {
                    Text("FixedWeekHeightStaticCalendar")
                }
                NavigationLink(
                    destination: CustomHeaderCalendarView()
                ) {
                    Text("CustomHeaderCalendar")
                }
            }
            .navigationTitle("Select Calendar")
        }
    }
}

#Preview {
    ContentView()
}
