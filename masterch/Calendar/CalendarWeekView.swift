//
//  CalendarWeekView.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/02/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarWeekView: UIView, WeekCalendarDateViewDelegate {
    var selectedDay: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate) {
        super.init(frame:frame)
        setUpDays(date)
    }
    
    func setUpDays(date: NSDate) {
        // 既にセットされてるdayViewの削除
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                view.removeFromSuperview()
            }
        }
        let daySize = CGSize(width: Int(frame.size.width / 7.0), height: Int(frame.size.width / 7.0))
        
        //今日を含む週の先頭（日曜日）の日にちをゲット
        // dayViewをaddする
        for var i = 0; i < 7; i++ {
            let x = i * Int(daySize.width)
            let frame = CGRect(origin: CGPoint(x: x, y: 0), size: daySize)
            let dayView = CalendarSwiftDateView(frame: frame, date: date + i.days)
            dayView.delegate = self
            self.addSubview(dayView)
            }
        }
    
    func onTapCalendarDayButton(sender: UIButton) {
        sender.selected = true
        if let selectedDay = selectedDay {
            selectedDay.selected = false
        }
        selectedDay = sender
    }
    
    func updateDayViewSelectedStatus() {
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                let dateView = view as! CalendarSwiftDateView
                if dateView.date == CalendarManager.selectedDate {
                    dateView.dayButton.selected = true
                } else {
                    dateView.dayButton.selected = false
                }
            }
        }
    }
}


