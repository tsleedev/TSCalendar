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
                    Text("FullSizeCalendarView")
                }
                NavigationLink(
                    destination: FixedWeekHeightCalendarView()
                ) {
                    Text("FixedWeekHeightCalendarView")
                }
                NavigationLink(
                    destination: CustomHeaderCalendarView()
                ) {
                    Text("CustomHeaderCalendarView")
                }
            }
            .navigationTitle("Select Calendar")
        }
    }
}

#Preview {
    ContentView()
}
