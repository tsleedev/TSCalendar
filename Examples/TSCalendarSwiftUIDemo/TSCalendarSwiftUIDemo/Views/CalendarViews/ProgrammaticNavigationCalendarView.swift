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
    @State private var autoSelectEnabled = true
    @State private var animatedEnabled = true

    var body: some View {
        VStack(spacing: 16) {
            // 설정 토글들
            VStack(spacing: 8) {
                Toggle("Auto Select", isOn: $autoSelectEnabled)
                    .onChange(of: autoSelectEnabled) { newValue in
                        controller.config.autoSelect = newValue
                    }

                Toggle("Animated", isOn: $animatedEnabled)
            }
            .padding(.horizontal)

            // 네비게이션 버튼들
            VStack(spacing: 12) {
                // 월 네비게이션
                HStack(spacing: 12) {
                    Button("Previous Month") {
                        moveToPreviousMonth()
                    }
                    .buttonStyle(.bordered)

                    Button("Next Month") {
                        moveToNextMonth()
                    }
                    .buttonStyle(.bordered)
                }

                Button("Move to Today") {
                    moveToToday()
                }
                .buttonStyle(.borderedProminent)

                // 일 네비게이션
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

    private func moveToPreviousMonth() {
        calendarRef?.moveMonth(by: -1, animated: animatedEnabled)
    }

    private func moveToNextMonth() {
        calendarRef?.moveMonth(by: 1, animated: animatedEnabled)
    }

    private func moveToPreviousDay() {
        calendarRef?.moveDay(by: -1, animated: animatedEnabled)
    }

    private func moveToNextDay() {
        calendarRef?.moveDay(by: 1, animated: animatedEnabled)
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
        // updateUIView는 SwiftUI가 자주 호출하므로,
        // reloadCalendar()를 매번 호출하면 ViewModel이 재생성되어 pendingAnimatedMove 상태가 손실됩니다.
        // Config가 실제로 변경되었을 때만 reload하도록 개선 필요하지만,
        // 현재는 불필요한 reload를 방지하기 위해 주석 처리합니다.
        // uiView.reloadCalendar()
    }
}

#Preview {
    ProgrammaticNavigationCalendarView()
}
