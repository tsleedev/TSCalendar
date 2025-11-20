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
    @State private var currentDisplayedDate = Date()
    @State private var selectedDate: Date? = .now

    var body: some View {
        VStack {
            HStack {
                // 이전 월/주 버튼
                Button(action: {
                    currentDisplayedDate = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: currentDisplayedDate
                    ) ?? currentDisplayedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }

                // 현재 날짜 텍스트
                Text(controller.headerTitle)
                    .font(.system(size: 17, weight: .semibold))

                // 다음 월/주 버튼
                Button(action: {
                    currentDisplayedDate = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: currentDisplayedDate
                    ) ?? currentDisplayedDate
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                // Today 버튼
                Button(action: {
                    selectedDate = .now
                    currentDisplayedDate = .now
                }) {
                    Text("Today")
                        .font(.system(size: 14))
                }

                // Collapse/Expand 버튼
                Button(action: {
                    controller.config.heightStyle = controller.config.heightStyle.isFlexible ? .fixed(60) : .flexible
                }) {
                    Text(controller.config.heightStyle.isFlexible ? "Collapse" : "Expand")
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 16)

            TSCalendar(
                currentDisplayedDate: $currentDisplayedDate,
                selectedDate: $selectedDate,
                config: controller.config,
                delegate: controller,
                dataSource: controller
            )

            if !controller.config.heightStyle.isFlexible {
                Spacer()
            }
        }
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
