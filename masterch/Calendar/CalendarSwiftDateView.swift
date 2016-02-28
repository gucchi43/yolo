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
        
        let dayButton = UIButton(frame: CGRect(x: 0, y: 0, width: w, height: h))
        dayButton.titleLabel?.textAlignment = NSTextAlignment.Center
        dayButton.setTitle(String(format: "%02d", date.day), forState: UIControlState.Normal)
        dayButton.addTarget(self, action: "onTapCalendarDayButton:", forControlEvents: .TouchUpInside)
        let nowday = NSDate().day
        
        print("day", date.day, "weekday", date.weekday)
        
        if date.weekday == 1 {
            //日曜日は赤
            dayButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        } else if date.weekday == 7 {
            //土曜日は青
            dayButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        } else if date.day == nowday{
            //今日は黒（※今は同じ日にち全部に反映されている）
            dayButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        } else {
            //普通はグレー
            dayButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }
        
        self.addSubview(dayButton)
    }
    
    func onTapCalendarDayButton(sender: UIButton) {
        print("onTapCalendarDayButton:")
        print("押した日付: \(sender.currentTitle)")
        sender.setTitleColor(UIColor.greenColor(), forState: .Normal)
    }

}

