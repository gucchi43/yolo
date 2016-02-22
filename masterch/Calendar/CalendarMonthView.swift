//
//  CalendarMonthView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit

class CalendarMonthView: UIView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, year: Int, month: Int) {
        super.init(frame:frame)
        setUpDays(year,month:month)
    }

    func setUpDays(year:Int, month:Int){
        // 既にセットされてるdayViewの削除
        let subViews:[UIView] = self.subviews as [UIView]
        for view in subViews {
            if view.isKindOfClass(CalendarDayView) {
                view.removeFromSuperview()
            }
        }
        
        let day = CalendarManager.getLastDay(year, month:month);
        let daySize = CGSize(width: Int(frame.size.width / 7.0), height: Int(frame.size.width / 7.0))
        
        //初日の曜日を取得
        var weekday = CalendarManager.getWeekDay(year, month: month, day: 1)
        
        // dayViewをaddする
        for var i = 0; i < day; i++ {
            let week = CalendarManager.getWeek(year, month: month, day: i + 1)
            let x = (weekday - 1) * Int(daySize.width)
            let y = (week - 1) * Int(daySize.height)
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: daySize)
            
            let dayView = CalendarDayView(frame: frame, year: year, month: month, day: i + 1, weekday: weekday)
            self.addSubview(dayView)
            weekday++
            if weekday > 7 {
                weekday = 1
            }
        }
    }
}
