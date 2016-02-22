//
//  CalendarDayView.swift
//  CrossCalendarSample
//
//  Created by Eisuke Sato on 2016/02/19.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit

class CalendarDayView: UIView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, year: Int, month: Int, day: Int, weekday: Int) {
        super.init(frame: frame)
        let dayWidth = Int((UIScreen.mainScreen().bounds.size.width) / 7)
        let dayHeight = 30
        
        let dayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: dayWidth, height: dayHeight))
        dayLabel.textAlignment = NSTextAlignment.Center
        dayLabel.text = String(format:"%02d", day)
        if weekday == 1 {
            //日曜日は赤
            dayLabel.textColor = UIColor.redColor()
        } else if weekday == 7 {
            //土曜日は青
            dayLabel.textColor = UIColor.blueColor()
        }
        
        self.addSubview(dayLabel)
    }
}
