//
//  CalendarSwiftDateView.swift
//  masterch
//
//  Created by HIroki Taniguti on 2016/02/28.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarSwiftDateView: UIView{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, date: NSDate)  {
        super.init(frame: frame)
        
        let w = Int((UIScreen.mainScreen().bounds.size.width) / 7)
        let h = 30
        
        let dayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
        dayLabel.textAlignment = NSTextAlignment.Center
        dayLabel.text = String(format:"%02d", date.day)
        dayLabel.textColor = UIColor.grayColor()
        let nowday = NSDate().day
        
        print("day", date.day, "weekday", date.weekday)
        if date.weekday == 1 {
            //日曜日は赤
            dayLabel.textColor = UIColor.redColor()
        } else if date.weekday == 7 {
            //土曜日は青
            dayLabel.textColor = UIColor.blueColor()
        } else if date.day == nowday{
            dayLabel.textColor = UIColor.blackColor()
        }
        
        self.addSubview(dayLabel)
    }
}

