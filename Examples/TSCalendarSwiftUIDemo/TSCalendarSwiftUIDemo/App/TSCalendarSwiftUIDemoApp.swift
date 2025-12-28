//
//  TSCalendarSwiftUIDemoApp.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/24/24.
//

import SwiftUI
import TSCalendar

@main
struct TSCalendarSwiftUIDemoApp: App {
    @State private var selectedDateFromWidget: Date?
    @State private var showingWidgetDateAlert = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleWidgetURL(url)
                }
                .alert("위젯에서 날짜 선택", isPresented: $showingWidgetDateAlert) {
                    Button("확인", role: .cancel) {
                        selectedDateFromWidget = nil
                    }
                } message: {
                    Text(formatSelectedDate())
                }
        }
    }

    private func formatSelectedDate() -> String {
        guard let date = selectedDateFromWidget else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ko_KR")
        return "\(formatter.string(from: date))이(가) 선택되었습니다."
    }

    private func handleWidgetURL(_ url: URL) {
        // URL Scheme: tscalendardemo://calendar?date=2025-01-15
        guard url.scheme == "tscalendardemo",
              url.host == "calendar",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let dateString = components.queryItems?.first(where: { $0.name == "date" })?.value else {
            return
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        if let date = formatter.date(from: dateString) {
            selectedDateFromWidget = date
            showingWidgetDateAlert = true
            print("📅 위젯에서 선택된 날짜: \(date)")
        }
    }
}
