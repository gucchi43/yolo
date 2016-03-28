//
//  CalendarMonthView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarMonthView: UIView, WeekCalendarDateViewDelegate {
    var selectedButton: UIButton!
    
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
        let lastDay = date.monthDays
        
        for var i = 0; i < lastDay; i++ {
            let mDate = date + i.days
            let week = mDate.weekOfMonth  // 何週目か
            let x = (mDate.weekday - 1) * Int(daySize.width)  // 曜日ごとにxの位置をずらす
            let y = (week - 1) * Int(daySize.height)  // 週毎にyの位置をずらす
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: daySize)  // frameの確定
            
            let dayView = CalendarSwiftDateView(frame: frame, date: mDate)
            dayView.delegate = self
            self.addSubview(dayView)
        }
    }
    
    func updateDayViewSelectedStatus() {
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarSwiftDateView) {
                let dateView = view as! CalendarSwiftDateView
                if dateView.date == CalendarManager.currentDate {
                    dateView.dayButton.backgroundColor = UIColor.yellowColor()
//                    dateView.dayButton.selected = true
//                    print("true")
                    print(dateView.date)
                } else {
                    dateView.dayButton.backgroundColor = UIColor.clearColor()
//                    dateView.dayButton.selected = false
//                    print("false")
                }
            }
        }
    }
}
