//
//  ProgrammaticNavigationCalendarView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by Claude on 1/25/25.
//

import SwiftUI
import TSCalendar

struct ProgrammaticNavigationCalendarView: View {
    @StateObject private var controller = CalendarController(
        config: TSCalendarConfig(
            scrollDirection: .vertical,
            showWeekNumber: true
        )
    )
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 16) {
            // 네비게이션 버튼들
            VStack(spacing: 12) {
                Button("Move to Today") {
                    moveToToday()
                }
                .buttonStyle(.borderedProminent)

                HStack(spacing: 12) {
                    Button("Previous Day") {
                        moveToPreviousDay()
                    }
                    .buttonStyle(.bordered)

                    Button("Next Day") {
                        moveToNextDay()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            // 달력 - UIKit 방식 사용
            CalendarViewWrapper(
                controller: controller,
                calendarRef: $calendarRef
            )
        }
        .navigationTitle("Programmatic Navigation")
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

    // MARK: - Calendar Reference
    @State private var calendarRef: TSCalendarUIView?

    // MARK: - Navigation Methods

    private func moveToToday() {
        calendarRef?.selectDate(Date())
    }

    private func moveToPreviousDay() {
        calendarRef?.moveDay(by: -1)
    }

    private func moveToNextDay() {
        calendarRef?.moveDay(by: 1)
    }
}

// MARK: - UIViewRepresentable Wrapper
private struct CalendarViewWrapper: UIViewRepresentable {
    let controller: CalendarController
    @Binding var calendarRef: TSCalendarUIView?

    func makeUIView(context: Context) -> TSCalendarUIView {
        let calendar = TSCalendarUIView(
            config: controller.config,
            delegate: controller,
            dataSource: controller
        )
        DispatchQueue.main.async {
            calendarRef = calendar
        }
        return calendar
    }

    func updateUIView(_ uiView: TSCalendarUIView, context: Context) {
        // Config 변경 시 reloadCalendar 호출
        uiView.reloadCalendar()
    }
}

#Preview {
    ProgrammaticNavigationCalendarView()
}
