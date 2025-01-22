//
//  WidgetWeekView.swift
//  TSCalendarSwiftUIDemo
//
//  Created by TAE SU LEE on 12/27/24.
//

import SwiftUI
import TSCalendar

struct WidgetWeekView : View {
    @StateObject private var controller = CalendarController()

    var body: some View {
        HStack {
            TSCalendar(
                config: .init(displayMode: .month),
                appearance: TSCalendarAppearance(type: .widget(.small)),
                delegate: controller,
                dataSource: controller
            )
            .frame(maxWidth: UIScreen.main.bounds.width / 2) // 너비를 화면의 절반으로 제한
            .padding(.vertical, 4)
            
            // 옆에 배치할 다른 콘텐츠
            VStack {
                Text("옆에 배치할 뷰")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    print("버튼 클릭!")
                }) {
                    Text("클릭")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity) // 나머지 공간을 차지
        }
        .frame(maxWidth: .infinity) // HStack이 화면 전체를 사용
    }
}


#if DEBUG
import WidgetKit

#Preview(as: .systemMedium) {
    WidgetDemo()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
}
#endif
